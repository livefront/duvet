import UIKit

/// `UIPresentationController` for presenting/dismissing the `SheetViewController`.
///
class SheetPresentationController: UIPresentationController {

    // MARK: Initialization

    /// Initialize a `SheetPresentationController`.
    ///
    /// - Parameters:
    ///   - presentedViewController: The view controller being presented modally.
    ///   - presenting: The view controller whose content represents the starting point of the transition.
    ///
    override init(presentedViewController: UIViewController, presenting: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presenting)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillChangeStatusBarFrame(notification:)),
            name: UIApplication.willChangeStatusBarFrameNotification,
            object: nil
        )
    }

    @objc private func handleWillChangeStatusBarFrame(notification: Notification) {
        // Pre-iOS 13, when the in-call status bar appears UIKit adjust's the containerView's frame
        // by 20pt to prevent the status bar from obscuring any content. However, when it's removed,
        // it does not adjust it back. This leaves an additional 20pt gap between the top of the
        // screen and the top of the view. When a sheet is presented with a dimmed background, this
        // results in the dimmed background view being 20pt from the top of the screen. Instead of
        // seeing the dimmed background behind the status bar, the background of the view controller
        // below the sheet shows through.
        //
        // This fixes that by resetting the container view's frame to match its window timed roughly
        // to match the status bar animation.
        if let containerView = containerView, let window = containerView.window {
            UIView.animate(withDuration: 0.33) {
                containerView.frame = window.frame
            }
        }
    }
}
