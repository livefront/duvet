import UIKit

/// Configuration parameters for controlling how a sheet's handle is displayed.
///
public struct SheetHandleConfiguration: Equatable {

    // MARK: Properties

    /// The handle view that should be displayed in the sheet.
    ///
    public let handleView: UIView

    /// The number of points that the handle should sit above the sheet. A negative value will move
    /// it into the sheet.
    public let topInset: CGFloat

    // MARK: Initialization

    /// Initialize a `SheetHandleConfiguration`.
    ///
    /// - Parameters:
    ///   - handle: The handle view that should be displayed in the sheet.
    ///   - topInset: The number of points that the handle should sit above the sheet. A negative
    ///     value will move it into the sheet.
    //
    public init(handleView: UIView = SheetHandleView(),
                topInset: CGFloat = 16) {
        self.handleView = handleView
        self.topInset = topInset
    }
}
