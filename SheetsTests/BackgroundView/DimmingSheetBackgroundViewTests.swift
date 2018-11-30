import XCTest

@testable import Sheets

class DimmingSheetBackgroundViewTests: XCTestCase {
    var subject: DimmingSheetBackgroundView!

    override func setUp() {
        super.setUp()

        subject = DimmingSheetBackgroundView()
    }

    /// `init` sets up the view.
    func testInit() {
        XCTAssertEqual(subject.alpha, 0)
    }

    /// `applyBackground` adds the background dimming.
    func testApplyBackground() {
        subject.applyBackground()

        XCTAssertEqual(subject.alpha, 0.5)
        XCTAssertEqual(subject.backgroundColor, .black)
    }

    /// `clearBackground` removes the background dimming.
    func testClearBackground() {
        subject.clearBackground()

        XCTAssertEqual(subject.alpha, 0)
    }
}
