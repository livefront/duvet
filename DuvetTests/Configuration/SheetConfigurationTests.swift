import XCTest

@testable import Duvet

class SheetConfigurationTests: XCTestCase {
    var subject: SheetConfiguration!

    override func setUp() {
        super.setUp()

        subject = SheetConfiguration()
    }

    /// `init` sets up the object.
    func testDefaultInit() {
        XCTAssertEqual(subject.cornerRadius, 10)
        XCTAssertNil(subject.handleConfiguration)
        XCTAssertEqual(subject.initialPosition, .open)
        XCTAssertTrue(subject.isKeyboardAvoidanceEnabled)
        XCTAssertEqual(subject.supportedPositions, [.open])
        XCTAssertEqual(subject.topInset, 44)
    }
}
