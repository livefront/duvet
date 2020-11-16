import XCTest

@testable import Duvet

class SheetTransitioningDelegateTests: XCTestCase {
    var sheetItem = SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil)
    var subject: SheetTransitioningDelegate!

    override func setUp() {
        super.setUp()

        subject = SheetTransitioningDelegate(duration: 0.3)
    }

    /// `init` sets up the object.
    func testInit() {
        XCTAssertEqual(subject.duration, 0.3)
    }

    /// `animationController(forPresented:presenting:source:)` returns the animation controller for presenting.
    func testAnimationControllerForPresented() {
        let animationController = subject.animationController(
            forPresented: SheetViewController(sheetItem: sheetItem),
            presenting: UIViewController(),
            source: UIViewController()
        )

        XCTAssertTrue(animationController is SheetAnimationController)
        XCTAssertEqual((animationController as? SheetAnimationController)?.duration, 0.3)
        XCTAssertEqual((animationController as? SheetAnimationController)?.isPresenting, true)

        XCTAssertNil(subject.animationController(
            forPresented: UIViewController(),
            presenting: UIViewController(),
            source: UIViewController()
        ))
    }

    /// `animationController(forDismissed:)` returns the animation controller for dismissing.
    func testAnimationControllerForDismissed() {
        let animationController = subject.animationController(
            forDismissed: SheetViewController(sheetItem: sheetItem)
        )

        XCTAssertTrue(animationController is SheetAnimationController)
        XCTAssertEqual((animationController as? SheetAnimationController)?.duration, 0.3)
        XCTAssertEqual((animationController as? SheetAnimationController)?.isPresenting, false)

        XCTAssertNil(subject.animationController(forDismissed: UIViewController()))
    }

    func testPresentationController() {
        let presentationController = subject.presentationController(
            forPresented: UIViewController(),
            presenting: UIViewController(),
            source: UIViewController()
        )

        XCTAssertTrue(presentationController is SheetPresentationController)
    }
}
