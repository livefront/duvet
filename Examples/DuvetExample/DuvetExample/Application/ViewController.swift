import Duvet
import UIKit

protocol ProvidesSheetConfiguration where Self: UIViewController {
    static var sheetConfiguration: SheetConfiguration { get }
}

protocol ProvidesSheetScrollView: AnyObject {
    var sheetScrollView: UIScrollView { get }
}

class ViewController: UIViewController {

    // MARK: Types

    enum Sheets: String, CaseIterable {
        case adjustable = "Adjustable"
        case adjustableWithScroll = "Adjustable with Scroll View"
        case blurredBackground = "Blurred Background"
        case customBackground = "Custom Background"
        case half = "Half Size"
        case fittingSize = "Fitting Size"
        case fullSize = "Full Size"
        case keyboard = "Keyboard - Fitting Size"               // Sheet handles adjusting contained view with keyboard.
        case keyboardFull = "Keyboard - Expand with Keyboard"   // Contained view responsible for keyboard adjustments.
        case pushPop = "Push/Pop"
        case scrollViewHeaderFooter = "Scroll View with Header and Footer"
        case statusBar = "Custom Status Bar"

        var backgroundView: SheetBackgroundView {
            switch self {
            case .blurredBackground:
                return BlurredSheetBackgroundView()
            case .customBackground:
                return CustomSheetBackgroundView()
            default:
                return DimmingSheetBackgroundView()
            }
        }

        var viewControllerType: BaseViewController.Type {
            switch self {
            case .adjustable:
                return AdjustableViewController.self
            case .adjustableWithScroll:
                return AdjustableWithScrollViewController.self
            case .blurredBackground:
                return BlurredBackgroundViewController.self
            case .customBackground:
                return CustomBackgroundViewController.self
            case .half:
                return HalfViewController.self
            case .fittingSize:
                return FittingSizeViewController.self
            case .fullSize:
                return FullSizeViewController.self
            case .keyboard:
                return KeyboardViewController.self
            case .keyboardFull:
                return KeyboardFullViewController.self
            case .pushPop:
                return PushPopViewController.self
            case .scrollViewHeaderFooter:
                return ScrollViewHeaderFooterViewController.self
            case .statusBar:
                return StatusBarViewController.self
            }
        }
    }

    // MARK: Properties

    weak var coordinator: AppCoordinator?

    let items = Sheets.allCases

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        presentedViewController?.preferredStatusBarStyle ?? .default
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sheets"

        view.backgroundColor = .white

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        modalPresentationCapturesStatusBarAppearance = true
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.rawValue
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        coordinator?.showSheetViewController(viewControllerType: item.viewControllerType, backgroundView: item.backgroundView, title: item.rawValue)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
