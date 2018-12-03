import XCTest

@testable import Sheets

class SheetViewTests: XCTestCase {
    var subject: SheetView!

    override func setUp() {
        super.setUp()

        subject = SheetView(view: UIView(), configuration: SheetConfiguration())
    }

    /// The sheet closed constraints account for moving the sheet offscreen even if the handle is above the sheet.
    func testClosedConstraintsHideHandle() {
        // No handle.
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 0)

        // Handle above the sheet.
        subject = SheetView(view: UIView(), configuration: SheetConfiguration(handleConfiguration: SheetHandleConfiguration(topInset: 16)))
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 16)

        // Handle in the sheet.
        subject = SheetView(view: UIView(), configuration: SheetConfiguration(handleConfiguration: SheetHandleConfiguration(topInset: -16)))
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 0)
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
