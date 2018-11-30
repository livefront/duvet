import XCTest

@testable import Sheets

class SheetViewTests: XCTestCase {
    var subject: SheetView!

    override func setUp() {
        super.setUp()

        subject = SheetView(view: UIView(), configuration: SheetConfiguration())
    }
}
