import Foundation

/// Delegate protocol for `SheetViewController`.
///
@MainActor
public protocol SheetViewControllerDelegate: AnyObject {

    /// The sheet view controller should be dismissed due to a tap in the background view.
    ///
    func dismissSheetViewController()
}
