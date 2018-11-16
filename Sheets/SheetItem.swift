import UIKit

/// Object containing the necessary information for displaying a sheet in a `SheetViewController`.
///
public struct SheetItem: Equatable {

    // MARK: Properties

    /// The configuration properties for displaying the sheet.
    let configuration: SheetConfiguration

    /// An optional scroll view that the sheet should track to allow adjusting the position of the sheet.
    let scrollView: UIScrollView?

    /// The view controller that should be displayed in the sheet.
    let viewController: UIViewController

    // MARK: Initialization

    /// Initialize a `SheetItem`.
    ///
    /// - Parameters:
    ///   - viewController: The view controller that should be displayed in the sheet.
    ///   - configuration: The configuration properties for displaying the sheet.
    ///   - scrollView: An optional scroll view that the sheet should track to allow adjusting the
    ///     position of the sheet.
    ///
    public init(viewController: UIViewController,
                configuration: SheetConfiguration,
                scrollView: UIScrollView?) {
        self.viewController = viewController
        self.configuration = configuration
        self.scrollView = scrollView
    }
}
