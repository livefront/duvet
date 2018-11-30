import UIKit

class BaseViewController: UIViewController {

    // MARK: Properties

    weak var coordinator: AppCoordinator?

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}
