import UIKit

/// A view controller that implements displaying a sheet above another view controller similar to
/// the Apple Maps app.
///
public class SheetViewController: UIViewController {

    // MARK: Properties

    /// The delegate of the view controller.
    public weak var delegate: SheetViewControllerDelegate?

    /// Property animator for dimming the background view as the sheet changes sizes.
    let backgroundDimmingAnimator: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        animator.scrubsLinearly = false
        animator.pausesOnCompletion = true
        return animator
    }()

    /// The view that is displayed behind the sheet view. This will dim when the sheet is in its
    /// fullest position.
    let backgroundView: SheetBackgroundView

    /// Object to manage the animation when pushing or popping sheets.
    let transitionManager: SheetTransitionManager

    /// An array of the sheet items being managed by the view controller.
    public private(set) var sheetItems = [SheetItem]()

    /// The current sheet being displayed.
    private(set) var sheetView: SheetView?

    /// The tap gesture recognizer for detecting taps on the background view that should dismiss the sheet.
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    // MARK: Initialization

    /// Initialize a `SheetViewController`.
    ///
    /// - Parameters:
    ///   - sheetItem: The `SheetItem` to display in the sheet.
    ///   - backgroundView: A background view that will dim behind the sheet.
    ///   - transitionManager: The object that manages sheet transitions.
    ///
    public init(sheetItem: SheetItem? = nil,
                backgroundView: SheetBackgroundView = DimmingSheetBackgroundView(),
                transitionManager: SheetTransitionManager = ForwardStackSheetTransitionManager()) {
        self.backgroundView = backgroundView
        self.transitionManager = transitionManager
        super.init(nibName: nil, bundle: nil)

        if let sheetItem = sheetItem {
            sheetItems = [sheetItem]
            transitionSheet(fromSheetItem: nil, toSheetItem: sheetItem, forward: true, animated: false)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(tapGestureRecognizer)
        backgroundView.isUserInteractionEnabled = false

        backgroundDimmingAnimator.addAnimations { [weak self] in
            self?.backgroundView.clearBackground()
        }

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.clearBackground()
        view.addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustViewForKeyboard(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustViewForKeyboard(notification:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }

    // MARK: Push/Pop Sheets

    /// Pushes a new sheet item onto the sheet stack.
    ///
    /// - Parameters:
    ///   - sheetItem: The sheet item to push onto the stack.
    ///   - animated: True if the transition between the current and new sheet should be animated.
    ///
    public func push(sheetItem: SheetItem, animated: Bool) {
        let fromSheetItem = sheetItems.last

        sheetItems.append(sheetItem)

        transitionSheet(fromSheetItem: fromSheetItem, toSheetItem: sheetItem, forward: true, animated: animated)
    }

    /// Pops the current sheet off of the sheet stack.
    ///
    /// - Parameter animated: True if the transition between the current and previous sheet should be animated.
    ///
    public func pop(animated: Bool) {
        let fromSheetItem = sheetItems.popLast()
        let toSheetItem = sheetItems.last

        transitionSheet(fromSheetItem: fromSheetItem, toSheetItem: toSheetItem, forward: false, animated: animated)
    }

    /// Replaces the sheet items currently in the sheet stack with the specified items.
    ///
    /// - Parameters:
    ///   - sheetItems: The sheet items to display in the stack.
    ///   - animated: True if the transition should be animated.
    ///
    public func setSheetItems(_ sheetItems: [SheetItem], animated: Bool) {
        let fromSheetItem = sheetItems.last
        self.sheetItems = sheetItems

        transitionSheet(fromSheetItem: fromSheetItem, toSheetItem: sheetItems.last, forward: true, animated: animated)
    }

    // MARK: Private

    /// Adds a sheet to the view controller and displays it.
    ///
    /// - Parameter sheetItem: The `SheetItem` containing the view controller and configuration to display.
    ///
    private func addSheet(_ sheetItem: SheetItem) {
        addChild(sheetItem.viewController)
        sheetItem.viewController.view.translatesAutoresizingMaskIntoConstraints = false

        let sheetView = SheetView(view: sheetItem.viewController.view, configuration: sheetItem.configuration)
        sheetView.delegate = self
        sheetView.scrollView = sheetItem.scrollView
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundAnimator = backgroundDimmingAnimator
        sheetView.willMove(toSuperview: view)
        view.addSubview(sheetView)

        NSLayoutConstraint.activate([
            sheetView.topAnchor.constraint(equalTo: view.topAnchor),
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        self.sheetView = sheetView
    }

    /// Adjusts the sheet based on the keyboard appearing or disappearing.
    ///
    /// - Parameter notification: The keyboard notification.
    ///
    @objc private func adjustViewForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }

        let keyboardFrameInView = view.convert(keyboardFrameEnd, from: nil)
        let keyboardFrameInSheet = keyboardFrameInView.intersection(sheetView?.frame ?? .zero)

        let animationCurveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveValue ?? UIView.AnimationOptions().rawValue)

        sheetView?.layoutIfNeeded()
        sheetView?.layoutManager.updateSheetForKeyboardHeight(keyboardFrameInSheet.height)
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.sheetView?.layoutIfNeeded()
        }, completion: nil)
    }

    /// Method to handle the background view being tapped.
    ///
    @objc private func handleTap() {
        view.endEditing(true)
        delegate?.dismissSheetViewController()
    }

    /// Transition between two sheets.
    ///
    /// - Parameters:
    ///   - from: The current sheet item that is being displayed.
    ///   - to: The new sheet item that should be displayed.
    ///   - forward: True when pushing a sheet, false when popping a sheet.
    ///   - animated: True if the transition should be animated.
    ///
    private func transitionSheet(fromSheetItem: SheetItem?, toSheetItem: SheetItem?, forward: Bool, animated: Bool) {
        guard let toSheetItem = toSheetItem else {
            delegate?.dismissSheetViewController()
            return
        }

        let fromSheetView = sheetView
        let fromViewController = fromSheetItem?.viewController
        fromSheetView?.backgroundAnimator = nil

        addSheet(toSheetItem)

        let toSheetView = sheetView
        let toViewController = toSheetItem.viewController

        let completion = {
            fromViewController?.willMove(toParent: nil)
            fromViewController?.removeFromParent()

            fromSheetView?.willMove(toSuperview: nil)
            fromSheetView?.removeFromSuperview()

            toViewController.didMove(toParent: self)
        }

        if animated {
            transitionManager.transition(
                fromSheetView: fromSheetView,
                toSheetView: toSheetView,
                in: view,
                forward: forward,
                completion: completion
            )
        } else {
            completion()
        }
    }
}

// MARK: - SheetViewDelegate

extension SheetViewController: SheetViewDelegate {
    func sheetViewMovedToClosePosition(_ sheetView: SheetView) {
        delegate?.dismissSheetViewController()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SheetViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}
