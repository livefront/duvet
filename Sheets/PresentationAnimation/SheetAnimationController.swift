import UIKit

/// Controller that manages animations for presenting and dismissing the `SheetViewController`.
///
public class SheetAnimationController: NSObject {

    // MARK: Properties

    /// The duration of the animation.
    let duration: TimeInterval

    /// True if `SheetViewController` is being presented, false otherwise.
    let isPresenting: Bool

    // MARK: Initialization

    /// Initialize a `SheetAnimationController`.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation that should be used when presenting or
    ///     dismissing the view controller.
    ///   - isPresenting: True if `SheetViewController` is being presented, false otherwise.
    ///
    public init(duration: TimeInterval, isPresenting: Bool) {
        self.duration = duration
        self.isPresenting = isPresenting
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SheetAnimationController: UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let viewControllerKey: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        guard let sheetViewController = transitionContext.viewController(forKey: viewControllerKey) as? SheetViewController else {
            transitionContext.completeTransition(false)
            return
        }

        // Setting the sheet's frame here fixes an issue when the sheet is presented with the
        // pre-iOS 13 in-call status bar being shown where the bottom of the sheet is 20pt below
        // the screen and the bottom of the sheet is cutoff.
        sheetViewController.view.frame = transitionContext.containerView.bounds
        transitionContext.containerView.addSubview(sheetViewController.view)

        if isPresenting {
            sheetViewController.sheetView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            if self.isPresenting {
                sheetViewController.sheetView?.transform = .identity
                sheetViewController.backgroundView.applyBackground()
            } else {
                sheetViewController.sheetView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
                sheetViewController.backgroundDimmingAnimator?.stopAnimation(true)
                sheetViewController.backgroundView.clearBackground()
            }
        }, completion: { _ in
            if self.isPresenting {
                sheetViewController.configureBackgroundAnimator()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
