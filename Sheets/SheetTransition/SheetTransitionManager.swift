import UIKit

/// Protocol for an object that manages the transition between two sheets.
///
public protocol SheetTransitionManager {

    /// Animates the transition from one sheet view to another.
    ///
    /// - Parameters:
    ///   - fromSheetView: The current sheet that is being displayed.
    ///   - toSheetView: The new sheet that will be displayed.
    ///   - view: The containing the sheet view.
    ///   - forward: True if the new sheet is being pushed, false for a pop.
    ///   - completion: Closure that should be called when the animation completes.
    ///
    func transition(fromSheetView: SheetView?,
                    toSheetView: SheetView?,
                    in view: UIView,
                    forward: Bool,
                    completion: @escaping () -> Void)
}
