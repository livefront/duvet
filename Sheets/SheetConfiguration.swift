import UIKit

/// Configuration parameters for controlling how the sheet view is displayed.
///
public struct SheetConfiguration: Equatable {

    // MARK: Properties

    /// The corner radius of the sheet.
    public var cornerRadius: CGFloat

    /// True if the handle for the sheet should be displayed.
    public var displaysHandle: Bool

    /// The number of points that the handle should sit above the sheet. A negative value will move
    /// it into the sheet.
    public var handleTopInset: CGFloat

    /// The sheets initial position.
    public var initialPosition: SheetPosition

    /// The list of positions that the view is allowed to adjusted to via panning the view.
    public var supportedPositions: [SheetPosition]

    /// The number of points that the sheet should sit below the top safe area.
    public var topInset: CGFloat

    // MARK: Initialization

    /// Initialize a `SheetConfiguration`.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the sheet.
    ///   - displaysHandle: True if the handle for the sheet should be displayed.
    ///   - initialPosition: The sheets initial position.
    ///   - supportedPositions: The list of positions that the view is allowed to be adjusted to via
    ///     panning the view.
    ///   - topInset: The number of points that the sheet should sit below the top safe area.
    ///
    public init(cornerRadius: CGFloat = 10,
                displaysHandle: Bool = true,
                handleTopInset: CGFloat = 16,
                initialPosition: SheetPosition = .open,
                supportedPositions: [SheetPosition] = [.open],
                topInset: CGFloat = 44) {
        self.cornerRadius = cornerRadius
        self.displaysHandle = displaysHandle
        self.handleTopInset = handleTopInset
        self.initialPosition = initialPosition
        self.supportedPositions = supportedPositions
        self.topInset = topInset
    }
}
