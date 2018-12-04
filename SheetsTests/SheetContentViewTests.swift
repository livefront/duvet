import XCTest

@testable import Sheets

class SheetContentViewTests: XCTestCase {
    var configuration: SheetConfiguration!
    var subject: SheetContentView!
    var view: UIView!

    override func setUp() {
        super.setUp()

        configuration = SheetConfiguration()
        view = UIView()

        subject = SheetContentView(view: view, configuration: configuration)
    }

    /// `init()` sets up the view.
    func testInit() {
        XCTAssertEqual(subject.layer.shadowColor, UIColor.black.cgColor)
        XCTAssertEqual(subject.layer.shadowOffset, CGSize(width: 0, height: 2))
        XCTAssertEqual(subject.layer.shadowOpacity, 0.1)
        XCTAssertEqual(subject.layer.shadowRadius, 8)

        XCTAssertEqual(view.layer.cornerRadius, 10)
        XCTAssertEqual(view.layer.maskedCorners, [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        XCTAssertTrue(view.layer.masksToBounds)
        XCTAssertTrue(subject.subviews.contains(view))
    }

    /// The sheet's corner radius can be adjusted in the configuration.
    func testSheetCornerRadius() {
        configuration = SheetConfiguration(cornerRadius: 4)
        subject = SheetContentView(view: view, configuration: configuration)

        XCTAssertEqual(view.layer.cornerRadius, 4)
    }

    /// A handle can be added to the view by including it in the configuration.
    func testAddHandle() {
        let handleConfiguration = SheetHandleConfiguration()
        configuration = SheetConfiguration(handleConfiguration: handleConfiguration)
        subject = SheetContentView(view: view, configuration: configuration)

        XCTAssertNotNil(subject.handleView)
        XCTAssertTrue(subject.subviews.contains(handleConfiguration.handleView))
    }

    /// `point(inside:with:)` returns true if the point is inside the contentView or handleView bounds.
    func testPointInside() {
        configuration = SheetConfiguration(handleConfiguration: SheetHandleConfiguration())
        subject = SheetContentView(view: view, configuration: configuration)

        subject.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        subject.layoutIfNeeded()

        XCTAssertFalse(subject.point(inside: CGPoint(x: 0, y: -12), with: nil))
        XCTAssertTrue(subject.point(inside: CGPoint(x: 50, y: -12), with: nil))
        XCTAssertTrue(subject.point(inside: CGPoint(x: 0, y: 60), with: nil))
    }

    /// `hitTest(_:with)` returns the view that contains the specified point.
    func testHitTest() {
        configuration = SheetConfiguration(handleConfiguration: SheetHandleConfiguration())
        subject = SheetContentView(view: view, configuration: configuration)

        subject.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        subject.layoutIfNeeded()

        XCTAssertNil(subject.hitTest(CGPoint(x: 0, y: -12), with: nil))
        XCTAssertTrue(subject.hitTest(CGPoint(x: 50, y: -12), with: nil) === subject.handleView)
        XCTAssertTrue(subject.hitTest(CGPoint(x: 20, y: -12), with: nil) === subject.handleView)
        XCTAssertTrue(subject.hitTest(CGPoint(x: 0, y: 60), with: nil) === view)
    }
}
