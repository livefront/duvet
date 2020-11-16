import Foundation

/// Delegate protocol for `SheetView`.
///
protocol SheetViewDelegate: class {

    /// The sheet has been moved offscreen and should be dismissed.
    ///
    func sheetViewMovedToClosePosition(_ sheetView: SheetView)
}
