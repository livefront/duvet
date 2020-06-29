import UIKit

/// Object that manages the constraints for moving the sheet between its supported positions.
///
struct SheetLayoutManager {

    // MARK: Properties

    /// A fractional value that indicates what percentage the sheet is covering the area between the
    /// top-most and second from top positions. 0.0 indicates that the sheet is scroll all the way
    /// up to the top position and the background should be dimmed. 1.0 indicates that the sheet is
    /// scrolled down the second from top position and the background should be clear.
    var backgroundDimmingFractionComplete: CGFloat? {
        guard let secondPosition = secondPosition else { return nil }

        let topPositionHeight = height(at: topPosition)
        let secondPositionHeight = height(at: secondPosition)
        let fractionComplete = 1 - ((contentHeightConstraint.constant - secondPositionHeight) / (topPositionHeight - secondPositionHeight))

        return fractionComplete
    }

    /// Content view constraints that move the sheet into the closed position when active.
    var closedConstraints = [NSLayoutConstraint]()

    /// The sheet's configuration that affects interactions and how it's displayed.
    let configuration: SheetConfiguration

    /// Constraint that anchors the content view to the bottom of the view (and is adjusted to move
    /// the content up when the keyboard appears).
    let contentBottomConstraint: NSLayoutConstraint

    /// Constant that defines the height of the content view when in the `opened` position.
    var contentHeightConstant: CGFloat {
        return max(0, sheetBounds.height - (sheetSafeAreaInsets.top + configuration.topInset + -contentBottomConstraint.constant))
    }

    /// Constraints that defines the height of the content view. This is adusted based on the
    /// current position and while panning the view.
    let contentHeightConstraint: NSLayoutConstraint

    /// Content view constraints that move the sheet into the half position when active.
    var halfConstraints = [NSLayoutConstraint]()

    /// Content view constraints that move the sheet into the fitting size position when active.
    var fittingSizeConstraints = [NSLayoutConstraint]()

    /// Constant that defines the height of the content view when in the `fittingSize` position.
    let fittingSizeHeightConstraint: NSLayoutConstraint

    /// Constant that defines the maximum height of the content view when in the `fittingSize`
    /// position. This limits the maximum size of the contentView to the height defined by the
    /// `open` position to prevent the view from growing too large.
    let fittingSizeMaxHeightConstraint: NSLayoutConstraint

    /// Content view constraints that are fixed regardless of the sheet's position.
    var fixedConstraints = [NSLayoutConstraint]()

    /// Content view constraints that move the sheet into the opened position when active.
    var openedConstraints = [NSLayoutConstraint]()

    // The sheet's current position.
    var position: SheetPosition = .closed

    /// The sheet view's bounds.
    var sheetBounds: CGRect = .zero {
        didSet {
            guard sheetBounds != oldValue else { return }
            updateConstraints()
        }
    }

    /// The sheet view's safe area insets.
    var sheetSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            guard sheetSafeAreaInsets != oldValue else { return }
            updateConstraints()
        }
    }

    /// The second from the top supported position for the sheet. This is used to fade the
    /// background to clear as the sheet is scrolled to this position.
    var secondPosition: SheetPosition? {
        let positions = positionsSortedByDistance(from: height(at: .open))
        guard positions.indices.contains(1) else { return nil }
        return positions[1].position
    }

    /// Weak reference to the sheet view.
    weak var sheetView: SheetView?

    /// The top-most supported position for the sheet.
    var topPosition: SheetPosition {
        return positionsSortedByDistance(from: height(at: .open)).first?.position ?? configuration.initialPosition
    }

    // MARK: Initialization

    /// Initialize a `SheetLayoutManager`.
    ///
    /// - Parameters:
    ///   - sheetView: The sheet view container.
    ///   - contentView: The content view for the sheet.
    ///   - configuration: The configuration parameters for the sheet.
    ///
    init(sheetView: SheetView, contentView: SheetContentView, configuration: SheetConfiguration) {
        self.sheetView = sheetView
        self.configuration = configuration

        contentBottomConstraint = contentView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor)
        contentHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        fittingSizeHeightConstraint = contentView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        fittingSizeMaxHeightConstraint = contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 0)

        setUpConstraints(sheetView: sheetView, contentView: contentView)
    }

    // MARK: Layout

    /// Adjusts the height of the content by yTranslation points. This should be called in response
    /// to the user panning on the view to slide the sheet up or down.
    ///
    /// - Parameter yTranslation: The number of points in the y-direction that the sheet should be
    ///     adjusted.
    ///
    func adjustContentHeight(with yTranslation: CGFloat) {
        contentHeightConstraint.constant = min(contentHeightConstant, height(at: position) - yTranslation)
    }

    /// Moves the sheet to a specific position.
    ///
    /// - Parameter position: The position to move the sheet to.
    ///
    mutating func move(to position: SheetPosition) {
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

    /// Returns a list of positions in the direction of the translation.
    ///
    /// - Parameter translation: The translation used to return the positions that exist in that direction.
    /// - Returns: A list of positions that exist in the direction of the translation value.
    ///
    func positionsInDirection(of translation: CGPoint) -> [SheetPosition] {
        guard !translation.y.isZero else { return configuration.supportedPositions }

        let currentHeight = contentHeightConstraint.constant

        // Determine how far the current position is away from the supported positions.
        let positionMappings = configuration.supportedPositions.map {
            return (position: $0, distance: distance(from: currentHeight, to: $0))
        }

        // Filter out the current position and any positions in the opposite direction of the pan translation.
        let positionsInTranslationDirection = positionMappings.filter {
            $0.position != position && ($0.distance > 0) == (translation.y > 0)
        }

        return positionsInTranslationDirection.map { $0.position }
    }

    /// Updates constraints for the sheet based on the sheet view's safe area and bounds. This
    /// should be called when the sheet view's bounds or safe area insets change.
    mutating func updateConstraints() {
        // Reset the height constraint to account for any heights that may be dependent on safe areas.
        contentHeightConstraint.constant = height(at: position)

        // Set the max height in `fittingSize` to be that of the `open` position.
        fittingSizeMaxHeightConstraint.constant = height(at: .open)
    }

    /// Adjusts the bottom of the sheet based on the height of the keyboard. If the sheet's position
    /// is `fittingSize` the sheet view will take care of adjusting the contained view to account
    /// for the keyboard. Otherwise, the contained view is responsible for keyboard adjustments;
    /// the sheet will just moved to the open position when the keyboard appears.
    ///
    /// - Parameter height: The height of the keyboard extending into the sheet view.
    ///
    mutating func updateSheetForKeyboardHeight(_ height: CGFloat) {
        guard position == .fittingSize else {
            if !height.isZero && position != .open && configuration.supportedPositions.contains(.open) {
                move(to: .open)
            }
            return
        }

        contentBottomConstraint.constant = -max(height, 0)
        contentHeightConstraint.constant = self.height(at: position)
    }

    // MARK: Position Calculations

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
    ///
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

    // MARK: Private

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

    /// Creates the constraints for adjusting the sheet between the supported positions.
    ///
    /// - Parameters:
    ///   - sheetView: The sheet view container.
    ///   - contentView: The content view for the sheet.
    ///
    private mutating func setUpConstraints(sheetView: SheetView, contentView: SheetContentView) {
        NSLayoutConstraint.deactivate(
            fixedConstraints +
            openedConstraints +
            halfConstraints +
            fittingSizeConstraints +
            closedConstraints
        )

        contentHeightConstraint.constant = contentHeightConstant
        contentHeightConstraint.priority = .init(999)
        fittingSizeMaxHeightConstraint.constant = contentHeightConstant

        fixedConstraints = [
            contentView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            contentView.topAnchor.constraint(
                greaterThanOrEqualTo: sheetView.safeAreaLayoutGuide.topAnchor,
                constant: configuration.topInset
            ),
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

        let handleInset = configuration.handleConfiguration?.topInset ?? 0
        closedConstraints = [
            // Extend the constraint constant `handleInset` points below the bottomAnchor, so that
            // the handle isn't seen when the sheet is in the closed position. `handleInset` can be
            // negative if the handle is in the sheet (as opposed to above it), so in that case, the
            // constraint constant should just be zero
            contentView.topAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: max(handleInset, 0)),
        ]
    }
}
