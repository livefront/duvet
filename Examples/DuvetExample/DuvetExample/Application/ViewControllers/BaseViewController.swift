import UIKit

/// The base view controller that is meant to be subclassed by all of the example sheet views.
/// Provides basic set up for the examples, but isn't necessary for displaying a sheet view.
///
class BaseViewController: UIViewController {

    // MARK: Properties

    /// A weak reference to the `AppCoordintor` used to dismiss the sheet.
    weak var coordinator: AppCoordinator?

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}
