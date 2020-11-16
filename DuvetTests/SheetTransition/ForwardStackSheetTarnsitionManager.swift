import XCTest

@testable import Duvet

class ForwardStackSheetTransitionManagerTests: XCTestCase {
    var fromSheetView: SheetView!
    var toSheetView: SheetView!
    var subject: ForwardStackSheetTransitionManager!
    var view: UIView!

    override func setUp() {
        super.setUp()

        fromSheetView = SheetView(view: UIView(), configuration: SheetConfiguration())
        toSheetView = SheetView(view: UIView(), configuration: SheetConfiguration())
        view = UIView()

        subject = ForwardStackSheetTransitionManager(duration: 0.1)
    }

    /// Transitioning with an animation animates the view swap and calls the completion handler.
    func testTransition() {
        let expectation = self.expectation(description: #function)
        var completionCalled = false

        subject.transition(fromSheetView: fromSheetView, toSheetView: toSheetView, in: view, forward: true) {
            completionCalled = true
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(completionCalled)
        XCTAssertEqual(fromSheetView.transform, CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height))
        XCTAssertEqual(toSheetView.transform, .identity)
    }

    /// Transitioning without an animation calls the completion handler.
    func testTransitionWithoutAnimation() {
        let expectation = self.expectation(description: #function)
        var completionCalled = false

        subject = ForwardStackSheetTransitionManager(duration: 0)
        subject.transition(fromSheetView: fromSheetView, toSheetView: toSheetView, in: view, forward: true) {
            completionCalled = true
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(completionCalled)
    }

    /// Transitioning forward keeps the `toSheetView` in front of the `fromSheetView`.
    func testTransitionForward() {
        view.addSubview(fromSheetView)
        view.addSubview(toSheetView)

        subject.transition(fromSheetView: fromSheetView, toSheetView: toSheetView, in: view, forward: true) {}

        XCTAssertEqual(view.subviews, [fromSheetView, toSheetView])
    }

    /// Transitioning backwards brings the `fromSheetView` to be in front of the `toSheetView`.
    func testTransitionBackward() {
        view.addSubview(fromSheetView)
        view.addSubview(toSheetView)

        subject.transition(fromSheetView: fromSheetView, toSheetView: toSheetView, in: view, forward: false) {}

        XCTAssertEqual(view.subviews, [toSheetView, fromSheetView])
    }
}
