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
}
