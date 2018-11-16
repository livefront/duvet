import XCTest

@testable import Sheets

class SheetAnimationControllerTests: XCTestCase {
    var subject: SheetAnimationController!

    override func setUp() {
        super.setUp()

        subject = SheetAnimationController(duration: 0.3, isPresenting: true)
    }

    /// `init` sets up the animation controller.
    func testInit() {
        XCTAssertEqual(subject.duration, 0.3)
        XCTAssertTrue(subject.isPresenting)
    }

    /// `animateTransition` animates the presentation of the view controller.
    func testPresentAnimateTransition() {
        subject = SheetAnimationController(duration: 0.1, isPresenting: true)

        let transitionContext = MockUIViewControllerContextTransitioning()
        let sheetItem = SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil)
        let sheetViewController = SheetViewController(sheetItem: sheetItem)
        transitionContext.toViewController = sheetViewController

        var didComplete = false

        let expectation = self.expectation(description: #function)
        transitionContext.didCompleteTransition = {
            didComplete = $0
            expectation.fulfill()
        }

        subject.animateTransition(using: transitionContext)

        XCTAssertTrue(transitionContext.containerView.subviews.contains(sheetViewController.view))

        waitForExpectations(timeout: 1)

        XCTAssertEqual(sheetViewController.sheetView?.contentView.transform, CGAffineTransform.identity)
        XCTAssertEqual(sheetViewController.backgroundView.alpha, 0.5)
        XCTAssertTrue(didComplete)
    }

    /// `animateTransition` animates the dismissal of the view controller.
    func testDismissAnimateTransition() {
        subject = SheetAnimationController(duration: 0.1, isPresenting: false)

        let transitionContext = MockUIViewControllerContextTransitioning()
        let sheetItem = SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil)
        let sheetViewController = SheetViewController(sheetItem: sheetItem)
        transitionContext.fromViewController = sheetViewController

        var didComplete = false

        let expectation = self.expectation(description: #function)
        transitionContext.didCompleteTransition = {
            didComplete = $0
            expectation.fulfill()
        }

        subject.animateTransition(using: transitionContext)

        waitForExpectations(timeout: 1)

        XCTAssertNotEqual(sheetViewController.sheetView?.contentView.transform, CGAffineTransform.identity)
        XCTAssertEqual(sheetViewController.backgroundView.alpha, 0.0)
        XCTAssertTrue(didComplete)
    }

    /// `transitionDuration(using:)` returns the duration of the transition.
    func testTransitionDuration() {
        XCTAssertEqual(subject.transitionDuration(using: nil), 0.3)
    }
}

class MockUIViewControllerContextTransitioning: NSObject, UIViewControllerContextTransitioning {
    var actions = [String]()
    var containerView = UIView()
    var didCompleteTransition: ((Bool) -> Void)?
    var finalFrame = CGRect.zero
    var fromViewController = UIViewController()
    var initialFrame = CGRect.zero
    var isAnimated = false
    var isInteractive = false
    var presentationStyle: UIModalPresentationStyle = .custom
    var toViewController = UIViewController()
    var targetTransform: CGAffineTransform = .identity
    var transitionWasCancelled = false

    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        actions.append("updateInteractiveTransition(\(percentComplete)) called")
    }

    func finishInteractiveTransition() {
        actions.append("updateInteractiveTransition() called")
    }

    func cancelInteractiveTransition() {
        actions.append("updateInteractiveTransition() called")
    }

    func pauseInteractiveTransition() {
        actions.append("updateInteractiveTransition() called")
    }

    func completeTransition(_ didComplete: Bool) {
        actions.append("updateInteractiveTransition(didComplete\(didComplete ? "true" : "false")) called")
        didCompleteTransition?(didComplete)
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        switch key {
        case  UITransitionContextViewControllerKey.from:
            return fromViewController
        case UITransitionContextViewControllerKey.to:
            return toViewController
        default:
            return nil
        }
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case  .from:
            return fromViewController.view
        case UITransitionContextViewKey.to:
            return toViewController.view
        default:
            return nil
        }
    }

    func initialFrame(for vc: UIViewController) -> CGRect {
        return initialFrame
    }

    func finalFrame(for vc: UIViewController) -> CGRect {
        return finalFrame
    }
}
