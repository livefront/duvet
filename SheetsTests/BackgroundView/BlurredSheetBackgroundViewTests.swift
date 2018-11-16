import XCTest

@testable import Sheets

class BlurredSheetBackgroundViewTests: XCTestCase {
    var subject: BlurredSheetBackgroundView!

    override func setUp() {
        super.setUp()

        subject = BlurredSheetBackgroundView()
    }

    /// `init` sets up the view.
    func testInit() {
        XCTAssertTrue(subject.subviews.contains(subject.visualEffectView))
        XCTAssertNil(subject.visualEffectView.effect)
    }

    /// `applyBackground` adds the background blur.
    func testApplyBackground() {
        subject.applyBackground()

        XCTAssertEqual(subject.visualEffectView.effect, subject.blurEffect)
    }

    /// `clearBackground` removes the background blur.
    func testClearBackground() {
        subject.clearBackground()

        XCTAssertNil(subject.visualEffectView.effect)
    }
}
