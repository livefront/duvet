import UIKit

// swiftlint:disable file_length

/// Container view for the contents of a sheet displayed in the `SheetViewController`.
///
public class SheetView: UIView {

    // MARK: Properties

    /// An animator that can be added to the view that will animate alongside the transitions
    /// between positions to clear the dimmed/blurred background when transitioning to the closed
    /// position.
    var backgroundAnimator: UIViewPropertyAnimator?

    /// The sheet's configuration that affects interactions and how it's displayed.
    let configuration: SheetConfiguration

    /// View containing the content that is displayed in the sheet.
    let contentView: SheetContentView

    /// The sheet view's delegate.
    weak var delegate: SheetViewDelegate?

    /// The initial content offset when the sheet interaction begins. This keeps the scroll view
    /// from scrolling while the sheet interaction is in progress.
    var initialContentOffset: CGPoint = .zero

    /// Object that manages the constraints to move the sheet between its supported positions.
    lazy var layoutManager = SheetLayoutManager(sheetView: self, contentView: contentView, configuration: configuration)

    /// The pan gesture recognizer that's responsible for adjusting the sheet height.
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(gestureRecognizer:)))
        recognizer.delegate = self
        return recognizer
    }()

    /// An optional scroll view that the sheet will track to allow adjusting the sheet height when
    /// the scroll view is at its top and it's still being panned down.
    /// Note: this replaces the scroll view's delegate and forwards any future delegate calls back to original delegate.
    var scrollView: UIScrollView? {
        didSet {
            scrollViewDelegate = scrollView?.delegate
            scrollView?.alwaysBounceVertical = true
            scrollView?.delegate = self
            scrollView?.panGestureRecognizer.addTarget(self, action: #selector(handle(gestureRecognizer:)))
        }
    }

    /// The original `UIScrollViewDelegate` on `scrollView`. Any scroll view delegate calls will be
    /// forwarded to this original delegate.
    weak var scrollViewDelegate: UIScrollViewDelegate?

    /// True when the sheet is being interactively moved up/down.
    var sheetInteractionInProgress = false

    /// Flag indicating that the scroll view should stop scrolling when dragging ends. This prevents
    /// scrolling the scroll view after panning to a new sheet position.
    var stopScrolling = false

    /// The initial translation of the pan gesture when the sheet interaction starts. This is used
    /// to calculate how far up/down the sheet should be adjusted.
    var translationAtInteractionStart: CGPoint = .zero

    // MARK: Initialization

    /// Initialize a `SheetView`.
    ///
    /// - Parameters:
    ///   - contentView: The view that occupies the sheet view.
    ///   - configuration: The configuration parameters for the sheet.
    ///
    init(view: UIView, configuration: SheetConfiguration) {
        self.configuration = configuration
        self.contentView = SheetContentView(view: view, configuration: configuration)
        super.init(frame: .zero)

        contentView.addGestureRecognizer(panGestureRecognizer)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        layoutManager.move(to: configuration.initialPosition)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Workaround for in-call status bar issues (pre-iOS 13). When the in-call status bar
        // appears or disappears, the sheet view is resized to fit below the status bar. When this
        // occurs, the layout manager needs to adjust the sheet accordingly.
        layoutManager.sheetBounds = bounds
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let contentViewPoint = contentView.convert(point, from: self)
        if contentView.point(inside: contentViewPoint, with: event) {
            return true
        }

        // Pass on points outside of the content view (specifically for the background/dimmed view).
        return false
    }

    override public func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        layoutManager.sheetSafeAreaInsets = safeAreaInsets
    }

    // MARK: CALayer

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return super.hitTest(point, with: event) }

        let contentViewPoint = contentView.convert(point, from: self)
        if let view = contentView.hitTest(contentViewPoint, with: event) {
            return view
        }

        return super.hitTest(point, with: event)
    }

    // MARK: NSObject

    override public func responds(to aSelector: Selector!) -> Bool {
        // Check if the selector should be forwarded to the scroll view delegate.
        guard let delegate = scrollViewDelegate, delegate.responds(to: aSelector) else {
            return super.responds(to: aSelector)
        }
        return true
    }

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        // Check if the selector should be forwarded to the scroll view delegate.
        guard let delegate = scrollViewDelegate, delegate.responds(to: aSelector) else {
            return super.forwardingTarget(for: aSelector)
        }
        return delegate
    }

    // MARK: Sheet Panning Adjustment

    /// Adjusts the sheet view based on the pan gesture recognizer.
    ///
    @objc func handle(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer {
        case scrollView?.panGestureRecognizer:
            if configuration.dismissKeyboardOnScroll {
                endEditing(true)
            }

            handleScrollViewPan(gestureRecognizer: gestureRecognizer)
        case panGestureRecognizer:
            handleSheetPan(gestureRecognizer: gestureRecognizer)
        default:
            break
        }
    }

    /// Handles the scroll view's pan gesture recognizer.
    ///
    /// - Parameter gestureRecognizer: The scroll view's pan gesture recognizer.
    ///
    private func handleScrollViewPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }

        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }

    /// Handles the sheet's pan gesture recognizer.
    ///
    /// - Parameter gestureRecognizer: The sheet's pan gesture recognizer.
    ///
    private func handleSheetPan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let location = gestureRecognizer.location(in: gestureRecognizer.view)

        // Determine if the scrollView should handle the gesture or if the user is interacting
        // with the sheet itself.
        guard shouldScrollViewHandleGesture(location: location) == false && shouldStartSheetInteraction(translation: translation) else {
            stopSheetInteraction()
            panningEnded(translation: translation, velocity: velocity)
            return
        }

        // Check if the sheet interaction needs stop (due to the sheet being at it's max
        // height). This lets the scroll view take over the gesture.
        if sheetInteractionInProgress && shouldStopSheetInteraction(translation: translation) {
            stopSheetInteraction()
            panningEnded(translation: translation, velocity: velocity)
            return
        }

        // Check if the sheet should start an interaction. This confirms that there's a
        // supported position in the direction of the pan translation.
        if !shouldStartSheetInteraction(translation: translation) {
            stopSheetInteraction()
            panningEnded(translation: translation, velocity: velocity)
            return
        }

        switch gestureRecognizer.state {
        case .began:
            startSheetInteraction(translation: translation)
        case .changed:
            startSheetInteraction(translation: translation)
            panningChanged(translation: translation)
        case .cancelled, .ended, .failed:
            stopSheetInteraction()
            panningEnded(translation: translation, velocity: velocity)
        case .possible:
            break
        @unknown default:
            break
        }
    }

    /// Method to handle a change in the pan gesture by adjusting the height of the sheet based on
    /// the translation of the pan gesture.
    ///
    /// - Parameter translation: The translation of the pan gesture.
    ///
    func panningChanged(translation: CGPoint) {
        // Scrolling down (positive y-translation) decreases the content height.
        let yTranslation = translation.y - translationAtInteractionStart.y

        layoutManager.adjustContentHeight(with: yTranslation)
        layoutIfNeeded()

        // Adjust the animator's fraction complete when moving between the top and second from top positions.
        if let fractionComplete = layoutManager.backgroundDimmingFractionComplete {

            // Always set isReversed to false since fractionComplete is calculated based on the animation going in the forward direction.
            backgroundAnimator?.isReversed = false

            // fractionComplete=0 (dim), fractionComplete=1 (clear).
            backgroundAnimator?.fractionComplete = min(max(fractionComplete, 0), 1)
        }

        // Prevent the scroll view from scrolling while the sheet interaction is in progress.
        scrollView?.contentOffset = initialContentOffset
    }

    /// Method to handle the end of the pan gesture. This moves the sheet to the target position
    /// based on the current direction and velocity of the pan.
    ///
    /// - Parameters:
    ///   - translation: The translation of the pan gesture.
    ///   - velocity: The velocity of the pan gesture.
    ///
    func panningEnded(translation: CGPoint, velocity: CGPoint) {
        let targetPosition = layoutManager.targetPosition(with: translation, velocity: velocity)

        let distanceToTarget = layoutManager.distance(from: layoutManager.contentHeightConstraint.constant, to: targetPosition)
        let velocityMagnitude = abs(velocity.y)
        let distanceMagnitude = abs(distanceToTarget)

        let duration: TimeInterval = 0.5
        let springVelocity: CGFloat
        if !distanceMagnitude.isZero && !duration.isZero {
            springVelocity = velocityMagnitude / distanceMagnitude / CGFloat(duration)
        } else {
            springVelocity = 0
        }

        layoutIfNeeded()
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: springVelocity,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.layoutManager.move(to: targetPosition)
                self.layoutIfNeeded()
            },
            completion: { _ in
                if targetPosition == .closed {
                    self.delegate?.sheetViewMovedToClosePosition(self)
                } else {
                    self.scrollView?.showsVerticalScrollIndicator = true
                    self.scrollView?.bounces = true
                }

                self.stopScrolling = false
            }
        )

        // Only animate the background when moving into or out of the closed position (i.e. between
        // the position above closed and closed).
        if let positionAboveClosed = layoutManager.positionAboveClosed,
           let animator = backgroundAnimator,
           targetPosition == positionAboveClosed || targetPosition == .closed {

            // The forward animation handles animating to the closed position (dimmed -> clear).
            // It needs to be reversed when animating back to dimmed.
            animator.isReversed = targetPosition == positionAboveClosed

            let completedValue: CGFloat = animator.isReversed ? 1 : 0
            if !animator.fractionComplete.isEqual(to: completedValue) {
                let timingParameters = UISpringTimingParameters(
                    dampingRatio: 0.9,
                    initialVelocity: CGVector(dx: 0, dy: springVelocity)
                )
                let durationFactor = CGFloat(duration / animator.duration)
                animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
            }
        }
    }

    /// Determines if the scroll view should handle the gesture or if it should be used to adjust
    /// the height of the sheet.
    ///
    /// - Parameter location: The point in the sheet view that identifies the location of the gesture.
    /// - Returns: True if the gesture should be handled by the scroll view.
    ///
    func shouldScrollViewHandleGesture(location: CGPoint) -> Bool {
        guard let scrollView = scrollView,
            scrollView.frame.contains(location),
            !sheetInteractionInProgress
            else {
                return false
        }

        if scrollView.contentOffset.y > 0 {
            return true
        }

        return false
    }

    /// Determines if a sheet interaction should start. This confirms that there are other supported
    /// positions in the direction of the translation.
    ///
    /// - Parameter translation: The translation of the pan gesture.
    /// - Returns: True if the sheet interaction should start.
    ///
    func shouldStartSheetInteraction(translation: CGPoint) -> Bool {
        return layoutManager.positionsInDirection(of: translation).count > 0
    }

    /// Determines if a sheet interaction should stop. Once an interaction starts, it should only
    /// stop if 1) the gesture ends or 2) the sheet has been scrolled to the top most position.
    /// Stopping the interaction allows the scroll view to start scrolling at the point.
    ///
    /// - Parameter translation: The translation of the pan gesture.
    /// - Returns: True if the sheet interaction should stop.
    ///
    func shouldStopSheetInteraction(translation: CGPoint) -> Bool {
        // If the sheet is at it's full height and the pan gesture is still moving up (negative y),
        // stop the sheet interaction.
        return translation.y - translationAtInteractionStart.y < 0 &&
            layoutManager.positionsInDirection(of: translation).count == 0
    }

    /// Starts the sheet interaction.
    ///
    /// This saves the current translation of the gesture and the scroll view's content offset to:
    /// 1) determine the distance to move the sheet
    /// 2) maintain the scroll view's content offset to prevent it from scrolling.
    ///
    /// - Parameter translation: The translation of the pan gesture.
    ///
    func startSheetInteraction(translation: CGPoint) {
        guard !sheetInteractionInProgress else { return }

        endEditing(true)

        translationAtInteractionStart = translation
        initialContentOffset = scrollView?.contentOffset ?? .zero

        sheetInteractionInProgress = true

        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.bounces = false
    }

    /// Stops the sheet interaction.
    ///
    func stopSheetInteraction() {
        guard sheetInteractionInProgress else { return }

        sheetInteractionInProgress = false

        stopScrolling = true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SheetView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer else { return false }

        // Recognize the pan gesture recognizer simultaneously with the scroll view's gesture recognizer.
        return otherGestureRecognizer === scrollView?.panGestureRecognizer
    }
}

// MARK: - UIScrollViewDelegate

extension SheetView: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)

        if stopScrolling {
            // Prevent the scroll view from scrolling as the sheet is dragged to a new position.
            targetContentOffset.pointee = initialContentOffset
            stopScrolling = false
        }
    }
}
