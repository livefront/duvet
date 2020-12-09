import Foundation

/// Delegate protocol for `SheetViewController`.
///
public protocol SheetViewControllerDelegate: class {

    /// The sheet view controller should be dismissed due to a tap in the background view.
    ///
    func dismissSheetViewController()
}
