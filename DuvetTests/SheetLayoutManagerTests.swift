import XCTest

@testable import Duvet

class SheetLayoutManagerTests: XCTestCase {
    var view: UIView!
    var sheetView: SheetView!
    var subject: SheetLayoutManager!

    override func setUp() {
        super.setUp()

        view = UIView()

        sheetView = SheetView(view: view, configuration: SheetConfiguration(supportedPositions: [.open, .half, .closed]))

        subject = sheetView.layoutManager
        subject.sheetBounds = CGRect(x: 0, y: 0, width: 600, height: 600)
    }

    /// `backgroundDimmingFractionComplete` returns a fraction value that indicates what percentage
    /// the sheet is covering the area between the position above closed and closed positions.
    func testBackgroundDimmingFractionComplete() {
        XCTAssertEqual(subject.backgroundDimmingFractionComplete, 0)

        subject.move(to: .half)
        XCTAssertEqual(subject.backgroundDimmingFractionComplete, 0)

        // Sheet height @ half = 278. Sheet height @ closed = 0.

        subject.contentHeightConstraint.constant = 208.5
        XCTAssertEqual(subject.backgroundDimmingFractionComplete, 0.25)

        subject.contentHeightConstraint.constant = 69.5
        XCTAssertEqual(subject.backgroundDimmingFractionComplete, 0.75)

        subject.move(to: .closed)
        XCTAssertEqual(subject.backgroundDimmingFractionComplete, 1)

        sheetView = SheetView(view: view, configuration: SheetConfiguration(supportedPositions: [.open]))
        XCTAssertNil(sheetView.layoutManager.backgroundDimmingFractionComplete)
    }

    /// `init()` sets up the constraints and moves the sheet to the initial position.
    func testInit() {
        XCTAssertEqual(subject.position, .open)
        XCTAssertTrue(subject.openedConstraints.allSatisfy { $0.isActive })
    }

    /// `contentHeightConstant` returns the expected height constant.
    func testContentHeightConstant() {
        XCTAssertEqual(subject.contentHeightConstraint.constant, 556)   // 556 = sheet height (600) - sheet configuration top inset (44)

        subject.sheetBounds = .zero
        XCTAssertEqual(subject.contentHeightConstant, UIScreen.main.bounds.height)
    }

    /// `adjustContentHeight(with:)` adjusts the height of the content based on the pan translation.
    func testAdjustContentHeight() {
        XCTAssertEqual(subject.contentHeightConstraint.constant, 556)   // 556 = sheet height (600) - sheet configuration top inset (44)

        subject.adjustContentHeight(with: 100)
        XCTAssertEqual(subject.contentHeightConstraint.constant, 556 - 100)

        subject.adjustContentHeight(with: -500)
        XCTAssertEqual(subject.contentHeightConstraint.constant, 556)
    }

    /// `move(to:)` can move the sheet to the half position.
    func testHalfPosition() {
        subject.move(to: .half)

        XCTAssertEqual(subject.position, .half)
        XCTAssertTrue(subject.halfConstraints.allSatisfy { $0.isActive })
        XCTAssertEqual(subject.contentHeightConstraint.constant, 556 / 2)   // 556 = sheet height (600) - sheet configuration top inset (44)
    }

    /// `move(to:)` can move the sheet to the fittingSize position.
    func testFittingSizePosition() {
        subject.move(to: .fittingSize)

        XCTAssertEqual(subject.position, .fittingSize)
        XCTAssertTrue(subject.fittingSizeConstraints.allSatisfy { $0.isActive })
        XCTAssertEqual(subject.contentHeightConstraint.constant, 0)
    }

    /// `move(to:)` can move the sheet to the closed position.
    func testClosedPosition() {
        subject.move(to: .closed)

        XCTAssertEqual(subject.position, .closed)
        XCTAssertTrue(subject.closedConstraints.allSatisfy { $0.isActive })
        XCTAssertEqual(subject.contentHeightConstraint.constant, 0)
    }

    /// `positionAboveClosed` returns the position immediately above the closed position.
    func testPositionAboveClosed() {
        XCTAssertEqual(subject.positionAboveClosed, .half)

        sheetView = SheetView(view: view, configuration: SheetConfiguration(supportedPositions: [.closed, .open]))
        subject = sheetView.layoutManager
        XCTAssertEqual(subject.positionAboveClosed, .open)

        sheetView = SheetView(view: view, configuration: SheetConfiguration(supportedPositions: [.open]))
        subject = sheetView.layoutManager
        XCTAssertNil(subject.positionAboveClosed)
    }

    /// `positionsInDirection(of:)` returns the supported positions in the direction of the translation.
    func testPositionsInDirection() {
        XCTAssertEqual(subject.positionsInDirection(of: CGPoint(x: 0, y: -5)), [])
        XCTAssertEqual(subject.positionsInDirection(of: CGPoint(x: 0, y: 5)), [.half, .closed])

        subject.move(to: .half)
        XCTAssertEqual(subject.positionsInDirection(of: CGPoint(x: 0, y: -5)), [.open])
        XCTAssertEqual(subject.positionsInDirection(of: CGPoint(x: 0, y: 5)), [.closed])
    }

    /// `updateSheetForKeyboardHeight(_:)` moves the sheet to the open position.
    func testUpdateSheetForKeyboardHeight() {
        subject.move(to: .half)
        subject.updateSheetForKeyboardHeight(100)

        XCTAssertEqual(subject.position, .open)
    }

    /// `updateSheetForKeyboardHeight(_:)` slides the sheet up when in the fittingSize position.
    func testUpdateSheetForKeyboardHeightFittingSize() {
        subject.move(to: .fittingSize)
        subject.updateSheetForKeyboardHeight(100)

        XCTAssertEqual(subject.contentHeightConstraint.constant, 0)
        XCTAssertEqual(subject.contentBottomConstraint.constant, -100)
    }

    /// The sheet closed constraints account for moving the sheet offscreen even if the handle is above the sheet.
    func testClosedConstraintsHideHandle() {
        // No handle.
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 0)

        // Handle above the sheet.
        let aboveSheetHandle = SheetView(
            view: UIView(),
            configuration: SheetConfiguration(handleConfiguration: SheetHandleConfiguration(topInset: 16))
        )
        subject = aboveSheetHandle.layoutManager
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 16)

        // Handle in the sheet.
        let inSheetHandle = SheetView(
            view: UIView(),
            configuration: SheetConfiguration(handleConfiguration: SheetHandleConfiguration(topInset: -16))
        )
        subject = inSheetHandle.layoutManager
        XCTAssertEqual(subject.closedConstraints.count, 1)
        XCTAssertEqual(subject.closedConstraints.first?.constant, 0)
    }

    /// `distance(from:to:)` returns the distance between a height and a position.
    func testDistance() {
        XCTAssertEqual(subject.distance(from: 100, to: .open), 100 - 556)
        XCTAssertEqual(subject.distance(from: 100, to: .closed), 100)
    }

    /// `targetPosition(with:velocity:)` returns the target position of the sheet based on the
    /// translation and velocity of a pan gesture.
    func testTargetPosition() {
        XCTAssertEqual(subject.targetPosition(with: CGPoint(x: 0, y: 0), velocity: .zero), .open)

        subject.adjustContentHeight(with: 100)
        XCTAssertEqual(subject.targetPosition(with: CGPoint(x: 0, y: 100), velocity: .zero), .open)

        subject.move(to: .open)
        subject.adjustContentHeight(with: 200)
        XCTAssertEqual(subject.targetPosition(with: CGPoint(x: 0, y: 100), velocity: CGPoint(x: 0, y: 200)), .half)
        XCTAssertEqual(subject.targetPosition(with: CGPoint(x: 0, y: 100), velocity: CGPoint(x: 0, y: -200)), .open)

        subject.move(to: .open)
        subject.adjustContentHeight(with: 556)  // 556 = sheet height (600) - sheet configuration top inset (44)
        XCTAssertEqual(subject.targetPosition(with: CGPoint(x: 0, y: 100), velocity: CGPoint(x: 0, y: 200)), .closed)
    }
}
