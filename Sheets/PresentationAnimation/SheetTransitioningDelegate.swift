import UIKit

/// `UIViewControllerTransitioningDelegate` for presenting/dismissing the `SheetViewController`.
///
public class SheetTransitioningDelegate: NSObject {

    // MARK: Properties

    /// The duration of the animation.
    let duration: TimeInterval

    // MARK: Initialization

    /// Initialize a `SheetTransitioningDelegate`.
    ///
    /// - Parameter duration: The duration of the animation that should be used when presenting or
    ///     dismissing the view controller.
    ///
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension SheetTransitioningDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is SheetViewController else { return nil }
        return SheetAnimationController(duration: duration, isPresenting: true)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed is SheetViewController else { return nil }
        return SheetAnimationController(duration: duration, isPresenting: false)
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return SheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
