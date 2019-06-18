import UIKit

/// Object that manages a sheet transition by sliding up a pushed sheet in front of the current
/// sheet. The pushed sheet is slid up in front of the current sheet while the current sheet is
/// slid down out of the view.
///
public class ForwardStackSheetTransitionManager {

    // MARK: Properties

    /// The duration in seconds of the animation.
    let duration: TimeInterval

    // MARK: Initialization

    /// Initialize a `ForwardStackSheetTransitionManager`.
    ///
    /// - Parameter duration: The duration in seconds of the animation.
    ///
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
}

// MARK: - SheetTransitionManager

extension ForwardStackSheetTransitionManager: SheetTransitionManager {
    public func transition(fromSheetView: SheetView?,
                           toSheetView: SheetView?,
                           in view: UIView,
                           forward: Bool,
                           completion: @escaping () -> Void) {
        guard !duration.isZero else {
            completion()
            return
        }

        let transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)

        if let fromSheetView = fromSheetView, !forward {
            view.bringSubviewToFront(fromSheetView)
        }

        view.layoutIfNeeded()

        toSheetView?.transform = transform

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            fromSheetView?.transform = transform
            toSheetView?.transform = .identity
        }, completion: { _ in
            completion()
        })
    }
}
