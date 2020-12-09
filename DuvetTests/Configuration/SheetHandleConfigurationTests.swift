import XCTest

@testable import Duvet

class SheetHandleConfigurationTests: XCTestCase {
    var subject: SheetHandleConfiguration!

    override func setUp() {
        super.setUp()

        subject = SheetHandleConfiguration()
    }

    /// `init` sets up the object.
    func testDefaultInit() {
        XCTAssertTrue(subject.handleView is SheetHandleView)
        XCTAssertEqual(subject.topInset, 16)
    }
}
