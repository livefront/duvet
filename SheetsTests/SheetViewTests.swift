import XCTest

@testable import Sheets

class SheetViewTests: XCTestCase {
    var backgroundAnimator: UIViewPropertyAnimator!
    var configuration: SheetConfiguration!
    var subject: SheetView!
    var view: UIView!

    override func setUp() {
        super.setUp()

        backgroundAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        backgroundAnimator.pausesOnCompletion = true

        configuration = SheetConfiguration(supportedPositions: [.open, .half, .closed])
        view = UIView()

        subject = SheetView(view: view, configuration: configuration)
        subject.backgroundAnimator = backgroundAnimator
    }

    /// `init(view:configuration)` sets up the view.
    func testInit() {
        XCTAssertTrue(subject.contentView.subviews.contains(view))
        XCTAssertTrue(subject.subviews.contains(subject.contentView))
        XCTAssertEqual(subject.contentView.gestureRecognizers, [subject.panGestureRecognizer])
        XCTAssertEqual(subject.layoutManager.position, .open)
    }

    /// `point(inside:with:)` returns true if the point is inside the contentView.
    func testPointInside() {
        subject.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        subject.layoutIfNeeded()

        XCTAssertFalse(subject.point(inside: CGPoint(x: -5, y: -5), with: nil))
        XCTAssertTrue(subject.point(inside: CGPoint(x: 5, y: 5), with: nil))
        XCTAssertTrue(subject.point(inside: CGPoint(x: 100, y: 100), with: nil))
    }

    /// `safeAreaInsetsDidChange()` notifies the layout manager of the safe area insets.
    func testSafeAreaInsetsDidChange() {
        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, UIScreen.main.bounds.height)

        // NOTE: `safeAreaInsets` can't be set directly, but we can use the fact that the layout
        // manager updates the constraints based on the bounds and safe area of the `SheetView`, so
        // updating the view's frame and calling `safeAreaInsetsDidChange` should update the
        // constraints as well.
        subject.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        subject.safeAreaInsetsDidChange()

        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, 556)
    }

    /// `hitTest(_:with)` returns the view that contains the specified point.
    func testHitTest() {
        let configuration = SheetConfiguration(handleConfiguration: SheetHandleConfiguration())
        subject = SheetView(view: view, configuration: configuration)

        subject.frame = UIScreen.main.bounds
        subject.safeAreaInsetsDidChange()
        subject.layoutIfNeeded()

        XCTAssertNil(subject.hitTest(CGPoint(x: -5, y: -5), with: nil))
        XCTAssertTrue(subject.hitTest(CGPoint(x: UIScreen.main.bounds.width / 2, y: 40), with: nil) ===
            configuration.handleConfiguration?.handleView)
        XCTAssertTrue(subject.hitTest(CGPoint(x: 5, y: 50), with: nil) === view)
    }

    /// The scroll view delegate methods get proxied so that the sheet view can intercept any
    /// delegate methods while the original delegate still receives them.
    func testProxiedScrollViewDelegateMethods() {
        let mockScrollViewDelegate = MockScrollViewDelegate()
        let scrollView = UIScrollView()
        scrollView.delegate = mockScrollViewDelegate

        subject.scrollView = scrollView

        XCTAssertTrue(scrollView.delegate === subject)
        XCTAssertTrue(subject.scrollViewDelegate === mockScrollViewDelegate)

        subject.scrollView?.delegate?.scrollViewDidScroll?(scrollView)
        XCTAssertEqual(mockScrollViewDelegate.actions.last, "scrollViewDidScroll")

        var targetContentOffset = CGPoint.zero
        subject.scrollView?.delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: .zero, targetContentOffset: &targetContentOffset)
        XCTAssertEqual(mockScrollViewDelegate.actions.last, "scrollViewWillEndDragging")
    }

    /// If the content offset of the scroll view is negative, it's reset to zero when a pan gesture occurs.
    func testHandleScrollViewGesture() {
        let scrollView = UIScrollView()
        subject.scrollView = scrollView

        scrollView.contentOffset = CGPoint(x: 0, y: -5)

        subject.handle(gestureRecognizer: scrollView.panGestureRecognizer)
        XCTAssertEqual(scrollView.contentOffset, CGPoint.zero)

        scrollView.contentOffset = CGPoint(x: 0, y: 5)

        subject.handle(gestureRecognizer: scrollView.panGestureRecognizer)
        XCTAssertEqual(scrollView.contentOffset, CGPoint(x: 0, y: 5))
    }

    /// `panningChanged(translation:)` updates the sheet content height.
    func testPanningChanged() {
        let translation = CGPoint(x: 0, y: 100)

        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, UIScreen.main.bounds.height)

        subject.startSheetInteraction(translation: CGPoint.zero)
        subject.panningChanged(translation: translation)

        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, UIScreen.main.bounds.height - 100)
    }

    /// `panningEnded(translation:velocity:)` moves the sheet to the targeted position based on the translation, velocity and supported positions.
    func testPanningEnded() {
        let translation = CGPoint(x: 0, y: 400)

        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, UIScreen.main.bounds.height)
        XCTAssertEqual(backgroundAnimator.fractionComplete, 0)

        subject.startSheetInteraction(translation: CGPoint.zero)
        subject.panningChanged(translation: translation)
        subject.panningEnded(translation: translation, velocity: CGPoint(x: 0, y: 100))

        XCTAssertEqual(subject.layoutManager.contentHeightConstraint.constant, UIScreen.main.bounds.height / 2)
    }

    /// `shouldScrollViewHandleGesture(location:)` determines if a pan gesture should be handled by the scroll view or the sheet.
    func testShouldScrollViewHandleGesture() {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        subject.scrollView = scrollView

        XCTAssertFalse(subject.shouldScrollViewHandleGesture(location: CGPoint(x: 0, y: 0)))

        scrollView.contentOffset = CGPoint(x: 0, y: 10)
        XCTAssertTrue(subject.shouldScrollViewHandleGesture(location: CGPoint(x: 0, y: 0)))
        XCTAssertFalse(subject.shouldScrollViewHandleGesture(location: CGPoint(x: 0, y: -5)))

        subject.startSheetInteraction(translation: .zero)
        XCTAssertFalse(subject.shouldScrollViewHandleGesture(location: CGPoint(x: 0, y: 0)))
    }

    /// `shouldStartSheetInteraction(translation:)` determines if a pan gesture should start a sheet
    /// interaction based on whether there are supported positions in the direction of the pan.
    func testShouldStartSheetInteraction() {
        XCTAssertFalse(subject.shouldStartSheetInteraction(translation: CGPoint(x: 0, y: -5)))
        XCTAssertTrue(subject.shouldStartSheetInteraction(translation: CGPoint(x: 0, y: 5)))

        subject = SheetView(view: view, configuration: SheetConfiguration(supportedPositions: [.open]))
        XCTAssertFalse(subject.shouldStartSheetInteraction(translation: CGPoint(x: 0, y: -5)))
        XCTAssertFalse(subject.shouldStartSheetInteraction(translation: CGPoint(x: 0, y: 5)))
    }

    /// `shouldStopSheetInteraction(translation:)` determines if a pan gesture should stop a sheet
    /// interaction based on whether there are supported positions in the direction of the pan.
    func testShouldStopSheetInteraction() {
        XCTAssertFalse(subject.shouldStopSheetInteraction(translation: CGPoint(x: 0, y: 5)))
        XCTAssertTrue(subject.shouldStopSheetInteraction(translation: CGPoint(x: 0, y: -5)))
    }

    /// The scroll view's pan gesture recognizer should be recognized simulatneously with the sheet view's pan gesture recognizer.
    func testGestureRecognizerShouldRecognizeSimultaneouslyWith() {
        let scrollView = UIScrollView()
        subject.scrollView = scrollView

        XCTAssertTrue(subject.gestureRecognizer(subject.panGestureRecognizer, shouldRecognizeSimultaneouslyWith: scrollView.panGestureRecognizer))
        XCTAssertFalse(subject.gestureRecognizer(subject.panGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIPanGestureRecognizer(target: nil, action: nil)))
    }

    /// When a sheet interaction finishes and the scroll view ends dragging, the original content offset is restored.
    func testScrollViewWillEndDragging() {
        let scrollView = UIScrollView()
        subject.scrollView = scrollView
        scrollView.contentOffset = CGPoint(x: 42, y: 42)

        var targetContentOffset = CGPoint.zero

        subject.scrollViewWillEndDragging(scrollView, withVelocity: CGPoint.zero, targetContentOffset: &targetContentOffset)
        XCTAssertEqual(targetContentOffset, .zero)

        subject.startSheetInteraction(translation: .zero)
        scrollView.contentOffset = CGPoint(x: 100, y: 100)
        subject.stopSheetInteraction()

        subject.scrollViewWillEndDragging(scrollView, withVelocity: CGPoint.zero, targetContentOffset: &targetContentOffset)
        XCTAssertEqual(targetContentOffset, CGPoint(x: 42, y: 42))
    }
}

class MockScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var actions = [String]()

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        actions.append("scrollViewDidScroll")
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        actions.append("scrollViewWillEndDragging")
    }
}
