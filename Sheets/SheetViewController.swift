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

    /// An array of the sheet items being managed by the view controller.
    private(set) var sheetItems = [SheetItem]()

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
    ///
    public init(sheetItem: SheetItem, backgroundView: SheetBackgroundView = DimmingSheetBackgroundView()) {
        self.backgroundView = backgroundView
        super.init(nibName: nil, bundle: nil)

        sheetItems = [sheetItem]
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

        if let sheetItem = sheetItems.last {
            addSheet(sheetItem)
        }
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
        view.addSubview(sheetView)

        NSLayoutConstraint.activate([
            sheetView.topAnchor.constraint(equalTo: view.topAnchor),
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        sheetItem.viewController.didMove(toParent: self)

        self.sheetView = sheetView
    }

    /// Method to handle the background view being tapped.
    ///
    @objc private func handleTap() {
        delegate?.dismissSheetViewController()
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
