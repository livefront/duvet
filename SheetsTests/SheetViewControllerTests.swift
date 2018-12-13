import XCTest

@testable import Sheets

class SheetViewControllerTests: XCTestCase {
    var delegate: MockSheetViewControllerDelegate!      // swiftlint:disable:this weak_delegate
    let sheetItem = SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil)
    var subject: SheetViewController!

    override func setUp() {
        super.setUp()

        delegate = MockSheetViewControllerDelegate()

        subject = SheetViewController(sheetItem: sheetItem)
        subject.delegate = delegate
    }

    /// `init` sets up the view.
    func testInit() {
        let backgroundView = BlurredSheetBackgroundView()
        subject = SheetViewController(sheetItem: sheetItem, backgroundView: backgroundView)

        XCTAssertTrue(subject.backgroundView === backgroundView)
        XCTAssertEqual(subject.sheetItems, [sheetItem])
    }

    /// `viewDidLoad()` adds the background view to the view controller.
    func testViewDidLoadAddsTheBackgroundView() {
        subject.viewDidLoad()

        XCTAssertTrue(subject.view.isUserInteractionEnabled)
        XCTAssertEqual(subject.view.gestureRecognizers, [subject.tapGestureRecognizer])
        XCTAssertTrue(subject.tapGestureRecognizer.delegate === subject)
        XCTAssertTrue(subject.view.subviews.contains(subject.backgroundView))
    }

    /// `viewDidLoad()` adds the first sheet to the view.
    func testViewDidLoadSetsUpTheFirstSheet() {
        subject.viewDidLoad()

        XCTAssertNotNil(subject.sheetView)
        guard let sheetView = subject.sheetView else {
            return XCTFail("Unable to get the sheet view.")
        }
        XCTAssertEqual(subject.children, [sheetItem.viewController])
        XCTAssertEqual(sheetView.backgroundAnimator, subject.backgroundDimmingAnimator)
        XCTAssertTrue(sheetView.contentView.contains(sheetItem.viewController.view))
    }

    /// When the background view is tapped, it requests that the delegate dismiss the view.
    func testBackgroundTapped() {
        subject.viewDidLoad()

        var dismissSheetViewControllerCalled = false
        delegate.didDismissSheetViewController = {
            dismissSheetViewControllerCalled = true
        }

        subject.tapGestureRecognizer.forceGestureRecognition()

        XCTAssertTrue(dismissSheetViewControllerCalled)
    }

    /// When the sheet view dismisses via a pan, the view controller requests that the delegate dismiss the view.
    func testSheetViewMovedToClosePosition() {
        subject.viewDidLoad()

        guard let sheetView = subject.sheetView else {
            return XCTFail("Unable to get the sheet view.")
        }

        var dismissSheetViewControllerCalled = false
        delegate.didDismissSheetViewController = {
            dismissSheetViewControllerCalled = true
        }

        subject.sheetViewMovedToClosePosition(sheetView)

        XCTAssertTrue(dismissSheetViewControllerCalled)
    }

    /// Pushing a sheet adds it to the stack and transitions the view to the current sheet.
    func testSheetPush() {
        subject.viewDidLoad()

        let viewController = UIViewController()
        let pushedSheetItem = SheetItem(viewController: viewController, configuration: SheetConfiguration(), scrollView: nil)

        subject.push(sheetItem: pushedSheetItem, animated: false)

        guard let sheetView = subject.sheetView else {
            return XCTFail("sheetView shouldn't be nil")
        }

        XCTAssertEqual(subject.sheetItems, [sheetItem, pushedSheetItem])
        XCTAssertTrue(sheetView.contentView.subviews.contains(viewController.view))
    }

    /// Popping a sheet removes it from the stack and transitions the view to the previous sheet.
    func testSheetPop() {
        subject.viewDidLoad()

        let viewController = UIViewController()
        let pushedSheetItem = SheetItem(viewController: viewController, configuration: SheetConfiguration(), scrollView: nil)

        subject.push(sheetItem: pushedSheetItem, animated: false)
        subject.pop(animated: false)

        guard let sheetView = subject.sheetView else {
            return XCTFail("sheetView shouldn't be nil")
        }

        XCTAssertEqual(subject.sheetItems, [sheetItem])
        XCTAssertTrue(sheetView.contentView.subviews.contains(sheetItem.viewController.view))
    }

    /// Setting the sheet items adds the sheet items to the stack and transitions to the last item in the array.
    func testSetSheetItems() {
        subject.viewDidLoad()

        let sheetItems = [
            SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil),
            SheetItem(viewController: UIViewController(), configuration: SheetConfiguration(), scrollView: nil),
        ]

        subject.setSheetItems(sheetItems, animated: false)

        guard let sheetView = subject.sheetView else {
            return XCTFail("sheetView shouldn't be nil")
        }

        XCTAssertEqual(subject.sheetItems, sheetItems)
        XCTAssertTrue(sheetView.contentView.subviews.contains(sheetItems[1].viewController.view))
    }
}

class MockSheetViewControllerDelegate: SheetViewControllerDelegate {
    var didDismissSheetViewController: (() -> Void)?

    func dismissSheetViewController() {
        didDismissSheetViewController?()
    }
}
