import UIKit

// swiftlint:disable file_length

/// Container view for the contents of a sheet displayed in the `SheetViewController`.
///
public class SheetView: UIView {

    // MARK: Properties

    /// An animator that can be added to the view that will animate alongside the transations from
    /// the top supported position to the second from top position. This is used to animate the
    /// background dim/blur as the sheet transations between the top two positions.
    var backgroundAnimator: UIViewPropertyAnimator?

    /// Content view constraints that move the sheet into the closed position when active.
    var closedConstraints = [NSLayoutConstraint]()

    /// The sheet's configuration that affects interactions and how it's displayed.
    let configuration: SheetConfiguration

    /// Constraint that anchors the content view to the bottom of the view (and is adjusted to move
    /// the content up when the keyboard appears).
    lazy var contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)

    /// Constant that defines the height of the content view when in the `opened` position.
    var contentHeightConstant: CGFloat {
        guard !bounds.isEmpty else { return UIScreen.main.bounds.height }
        return max(0, bounds.height - (safeAreaInsets.top + configuration.topInset + -contentBottomConstraint.constant))
    }

    /// Constraints that defines the height of the content view. This is adusted based on the
    /// current position and while panning the view.
    lazy var contentHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)

    /// View containing the content that is displayed in the sheet.
    lazy var contentView = UIView()

    /// The sheet view's delegate.
    weak var delegate: SheetViewDelegate?

    /// Content view constraints that move the sheet into the half position when active.
    var halfConstraints = [NSLayoutConstraint]()

    /// The initial content offset when the sheet interaction begins. This keeps the scroll view
    /// from scrolling while the sheet interaction is in progress.
    var initialContentOffset: CGPoint = .zero

    /// Content view constraints that move the sheet into the fitting size position when active.
    var fittingSizeConstraints = [NSLayoutConstraint]()

    /// Constant that defines the height of the content view when in the `fittingSize` position.
    lazy var fittingSizeHeightConstraint = contentView.heightAnchor.constraint(equalTo: contentView.heightAnchor)

    /// Constant that defines the maximum height of the content view when in the `fittingSize`
    /// position. This limits the maximum size of the contentView to the height defined by the
    /// `open` position to prevent the view from growing too large.
    lazy var fittingSizeMaxHeightConstraint = contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 0)

    /// Content view constraints that are fixed regardless of the sheet's position.
    var fixedConstraints = [NSLayoutConstraint]()

    /// The handle for the sheet to indicate that it supports dragging the view up/down.
    let handleView = SheetHandleView()

    /// The pan gesture recognizer that's responsible for adjusting the sheet height.
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(gestureRecognizer:)))
        recognizer.delegate = self
        return recognizer
    }()

    // The sheet's current position.
    var position: SheetPosition = .closed

    /// Content view constraints that move the sheet into the opened position when active.
    var openedConstraints = [NSLayoutConstraint]()

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

    /// The second from the top supported position for the sheet.
    var secondPosition: SheetPosition? {
        let positions = positionsSortedByDistance(from: height(at: .open))
        guard positions.indices.contains(1) else { return nil }
        return positions[1].position
    }

    /// True when the sheet is being interactively moved up/down.
    var sheetInteractionInProgress = false

    /// Flag indicating that the scroll view should stop scrolling when dragging ends. This prevents
    /// scrolling the scroll view after panning to a new sheet position.
    var stopScrolling = false

    /// The top-most supported position for the sheet.
    var topPosition: SheetPosition {
        return positionsSortedByDistance(from: height(at: .open)).first?.position ?? configuration.initialPosition
    }

    /// The initial translation of the pan gesture when the sheet interaction starts. This is used
    /// to calculate how far up/down the sheet should be adjusted.
    var translationAtInteractionStart: CGPoint = .zero

    /// UIEdgeInsets for the contentView which includes the handle view's position.
    private var contentTouchInsets: UIEdgeInsets {
        guard let handleConfiguration = configuration.handleConfiguration else { return .zero }
        let yInset = min(-handleConfiguration.topInset - 16, 0)
        return UIEdgeInsets(top: yInset, left: 0, bottom: 0, right: 0)
    }

    // MARK: Initialization

    /// Initialize a `SheetView`.
    ///
    /// - Parameters:
    ///   - contentView: The view that occupies the sheet view.
    ///   - configuration: The configuration parameters for the sheet.
    ///
    init(view: UIView, configuration: SheetConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        view.layer.cornerRadius = configuration.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])

        if let handleConfiguration = configuration.handleConfiguration {
            handleView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(handleView)

            NSLayoutConstraint.activate([
                handleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -handleConfiguration.topInset),
                handleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                ])
        }

        setUpContentView()

        move(to: configuration.initialPosition)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        backgroundAnimator?.stopAnimation(true)
    }

    // MARK: UIView

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let handleViewPoint = convert(point, to: contentView)
        if contentView.frame.contains(point) || handleView.frame.contains(handleViewPoint) {
            return true
        }

        // Pass on points outside of the content view (specifically for the background/dimmed view).
        return false
    }

    // MARK: CALayer

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return super.hitTest(point, with: event) }

        if contentView.frame.contains(point) {
            let contentViewPoint = convert(point, to: contentView)
            return contentView.hitTest(contentViewPoint, with: event)
        }

        // Extend the handleView's tappable area slightly larger than its small frame.
        let handleViewPoint = convert(point, to: contentView)
        if handleView.frame.insetBy(dx: -16, dy: -16).contains(handleViewPoint) {
            return handleView
        }

        return super.hitTest(point, with: event)
    }

    override public func safeAreaInsetsDidChange() {
        // Reset the height constraint to account for any heights that may be dependent on safe areas.
        contentHeightConstraint.constant = height(at: position)

        // Set the max height in `fittingSize` to be that of the `open` position.
        fittingSizeMaxHeightConstraint.constant = height(at: .open)
    }

    // MARK: Keyboard Adjustment

    /// Adjusts the bottom of the sheet based on the height of the keyboard. If the sheet's position
    /// is `fittingSize` the sheet view will take care of adjusting the contained view to account
    /// for the keyboard. Otherwise, the contained view is responsible for keyboard adjustments;
    /// the sheet will just moved to the open position when the keyboard appears.
    ///
    /// - Parameter height: The height of the keyboard extending into the sheet view.
    ///
    func updateSheetForKeyboardHeight(_ height: CGFloat) {
        guard position == .fittingSize else {
            if !height.isZero && position != .open && configuration.supportedPositions.contains(.open) {
                move(to: .open)
            }
            return
        }

        contentBottomConstraint.constant = -max(height, 0)
        contentHeightConstraint.constant = self.height(at: position)
    }

    // MARK: Private

    /// Configures the `contentView` and its constraints for the different sheet positions.
    ///
    private func setUpContentView() {
        panGestureRecognizer.addTarget(self, action: #selector(handle(gestureRecognizer:)))
        panGestureRecognizer.delegate = self

        contentView.addGestureRecognizer(panGestureRecognizer)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 8

        NSLayoutConstraint.deactivate(
            fixedConstraints +
            openedConstraints +
            halfConstraints +
            fittingSizeConstraints +
            closedConstraints
        )

        contentHeightConstraint.constant = contentHeightConstant
        fittingSizeMaxHeightConstraint.constant = contentHeightConstant

        fixedConstraints = [
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]

        openedConstraints = [
            contentBottomConstraint,
            contentHeightConstraint,
        ]

        halfConstraints = [
            contentBottomConstraint,
            contentHeightConstraint,
        ]

        fittingSizeConstraints = [
            contentBottomConstraint,
            fittingSizeHeightConstraint,
            fittingSizeMaxHeightConstraint,
        ]
        fittingSizeHeightConstraint.priority = .init(999)

        closedConstraints = [
            contentView.topAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ]
    }

    /// Returns the height that the sheet view should have when it's in the specified position.
    ///
    /// - Parameter position: The position of the sheet view to return the height for.
    /// - Returns: The height of the sheet view in the specified position.
    ///
    private func height(at position: SheetPosition) -> CGFloat {
        switch position {
        case .closed:
            return 0
        case .half:
            return contentHeightConstant / 2
        case .fittingSize:
            // `fittingSize` height is driven by `fittingSizeHeightConstraint` not
            // `contentHeightConstraint` so 0 can be returned.
            return 0
        case .open:
            return contentHeightConstant
        }
    }

    /// Moves the sheet to a specific position.
    ///
    /// - Parameter position: The position to move the sheet to.
    ///
    func move(to position: SheetPosition) {
        NSLayoutConstraint.deactivate(
            openedConstraints +
            halfConstraints +
            fittingSizeConstraints +
            closedConstraints
        )

        NSLayoutConstraint.activate(fixedConstraints)

        switch position {
        case .closed:
            NSLayoutConstraint.activate(closedConstraints)
        case .half:
            NSLayoutConstraint.activate(halfConstraints)
        case .fittingSize:
            NSLayoutConstraint.activate(fittingSizeConstraints)
        case .open:
            NSLayoutConstraint.activate(openedConstraints)
        }

        contentHeightConstraint.constant = height(at: position)

        self.position = position
    }
}

// MARK: Sheet Panning Adjustment

extension SheetView {

    /// Adjusts the sheet view based on the pan gesture recognizer.
    ///
    @objc private func handle(gestureRecognizer: UIPanGestureRecognizer) {
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
        guard shouldScrollViewHandleGesture(location: location) == false else {
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

        contentHeightConstraint.constant = min(contentHeightConstant, height(at: position) - yTranslation)
        layoutIfNeeded()

        // Adjust the animator's fraction complete when moving between the top and second from top positions.
        if let secondPosition = self.secondPosition {
            let topPositionHeight = height(at: topPosition)
            let secondPositionHeight = height(at: secondPosition)
            let fractionComplete = 1 - ((contentHeightConstraint.constant - secondPositionHeight) / (topPositionHeight - secondPositionHeight))

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
        let targetPositon = targetPosition(with: translation, velocity: velocity)

        let distanceToTarget = distance(from: contentHeightConstraint.constant, to: targetPositon)
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
                self.move(to: targetPositon)
                self.layoutIfNeeded()
            },
            completion: { _ in
                if targetPositon == .closed {
                    self.delegate?.sheetViewMovedToClosePosition(self)
                } else {
                    self.scrollView?.showsVerticalScrollIndicator = true
                    self.scrollView?.bounces = true
                }

                self.stopScrolling = false
            }
        )

        // Only animate the background when moving between the top and second from top positions.
        if let secondPosition = self.secondPosition,
            let animator = backgroundAnimator,
            secondPosition == targetPositon || topPosition == targetPositon {

            // The animation is reversed when animating from the top to the second positions
            // (dimmed -> clear). It needs to be reversed when animating back to dimmed.
            animator.isReversed = targetPositon == topPosition

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
        guard !translation.y.isZero else { return false }

        let currentHeight = contentHeightConstraint.constant

        // Determine how far the current position is away from the supported positions.
        let positionMappings = configuration.supportedPositions.map {
            return (position: $0, distance: distance(from: currentHeight, to: $0))
        }

        // Filter out the current position and any positions in the opposite direction of the pan translation.
        let positionsInTranslationDirection = positionMappings.filter {
            $0.position != position && ($0.distance > 0) == (translation.y > 0)
        }

        return positionsInTranslationDirection.count > 0
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
            contentHeightConstraint.constant == contentHeightConstant
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

// MARK: Position Distance Calculations

extension SheetView {

    /// Calculates the distance between the height of the sheet and the height at a specified position.
    ///
    /// - Parameters:
    ///   - height: The current height of the sheet.
    ///   - position: The position of the sheet to return the distance from the current height.
    /// - Returns: The difference between the current height and the height of the sheet in the
    ///     specified position.
    ///
    func distance(from height: CGFloat, to position: SheetPosition) -> CGFloat {
        let positionHeight = self.height(at: position)
        return height - positionHeight
    }

    /// Return the list of supported positions for the sheet sorted by the distance from the specified height.
    ///
    /// - Parameter height: The height of the sheet to calculate the distance to each of the supported positions.
    /// - Returns: An array of tuples containing the position and the sheet
    func positionsSortedByDistance(from height: CGFloat) -> [(position: SheetPosition, distance: CGFloat)] {
        // Determine how far the current position is away from the supported positions.
        let positionMappings = configuration.supportedPositions.map {
            return (position: $0, distance: distance(from: height, to: $0))
        }
        return positionMappings.sorted { abs($0.distance) < abs($1.distance) }
    }

    /// Determines the target position of the sheet based on the translation and velocity of the pan
    /// gesture.
    ///
    /// - Parameters:
    ///   - translation: The translation of the pan gesture.
    ///   - velocity: The velocity of the pan gesture.
    /// - Returns: The target position that the sheet should move to base on the final values of the
    ///     pan gesture.
    ///
    func targetPosition(with translation: CGPoint, velocity: CGPoint) -> SheetPosition {
        let currentHeight = contentHeightConstraint.constant

        // Determine how far the current position is away from the supported positions.
        let positionMappings = configuration.supportedPositions.map {
            return (position: $0, distance: distance(from: currentHeight, to: $0))
        }
        let sortedByDistance = positionMappings.sorted { abs($0.distance) < abs($1.distance) }

        // The velocity theshold at which a pan should be allowed to change the position of the sheet.
        let changePositionVelocityThreshold: CGFloat = 150

        let targetPosition: SheetPosition?
        if velocity.y > changePositionVelocityThreshold {
            // Scrolling down; target position should be the next closest position in the
            // positive-y direction. (We don't want to return to a position that was passed).
            targetPosition = sortedByDistance.filter { $0.distance >= 0 }.first?.position
        } else if velocity.y < -changePositionVelocityThreshold {
            // Scrolling up; target position should be the next closest position in the negative-y
            // direction. (We don't want to return to a position that was passed).
            targetPosition = sortedByDistance.filter { $0.distance <= 0 }.first?.position
        } else {
            // If y-velocity == 0, target position is the closest position.
            targetPosition = sortedByDistance.first?.position
        }

        return targetPosition ?? position
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
        if stopScrolling {
            // Prevent the scroll view from scrolling as the sheet is dragged to a new position.
            targetContentOffset.pointee = initialContentOffset
            stopScrolling = false
        }
    }
}
