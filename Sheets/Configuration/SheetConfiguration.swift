import UIKit

/// Configuration parameters for controlling how the sheet view is displayed.
///
public struct SheetConfiguration: Equatable {

    // MARK: Properties

    /// The corner radius of the sheet.
    public var cornerRadius: CGFloat

    /// Configuration parameters for displaying a sheet's handle.
    public var handleConfiguration: SheetHandleConfiguration?

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
    ///   - handleConfiguration: Configuration parameters for displaying a sheet handle.
    ///   - initialPosition: The sheets initial position.
    ///   - supportedPositions: The list of positions that the view is allowed to be adjusted to via
    ///     panning the view.
    ///   - topInset: The number of points that the sheet should sit below the top safe area.
    ///
    public init(cornerRadius: CGFloat = 10,
                handleConfiguration: SheetHandleConfiguration? = nil,
                initialPosition: SheetPosition = .open,
                supportedPositions: [SheetPosition] = [.open],
                topInset: CGFloat = 44) {
        self.cornerRadius = cornerRadius
        self.handleConfiguration = handleConfiguration
        self.initialPosition = initialPosition
        self.supportedPositions = supportedPositions
        self.topInset = topInset
    }
}