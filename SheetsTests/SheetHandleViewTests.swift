import XCTest

@testable import Sheets

class SheetHandleViewTests: XCTestCase {
    var subject: SheetHandleView!

    override func setUp() {
        super.setUp()

        subject = SheetHandleView()
    }

    // `init` sets up the view.
    func testInit() {
        XCTAssertFalse(subject.layer.masksToBounds)
        XCTAssertEqual(subject.layer.shadowColor, UIColor.black.cgColor)
        XCTAssertEqual(subject.layer.shadowOffset, CGSize(width: 0, height: 2))
        XCTAssertEqual(subject.layer.shadowOpacity, 0.1)
        XCTAssertEqual(subject.layer.shadowRadius, 8)

        XCTAssertTrue(subject.subviews.contains(subject.handleView))

        XCTAssertEqual(subject.handleView.backgroundColor, .white)
        XCTAssertEqual(subject.handleView.layer.cornerRadius, 4)
    }
}
