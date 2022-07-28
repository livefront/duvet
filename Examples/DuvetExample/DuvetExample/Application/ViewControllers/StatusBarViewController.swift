import Duvet
import UIKit

/// Constants that describe the style of the device’s status bar.
enum StatusBarStyle: CaseIterable {
    static var allCases: [StatusBarStyle] {
        var styles: [StatusBarStyle] = [.default, .light]
        if #available(iOS 13.0, *) {
            styles.append(.dark)
        }
        return styles
    }

    /// A status bar that automatically chooses light or dark content based on the user interface style.
    case `default`

    /// A light status bar, intended for use on dark backgrounds.
    case light

    /// A light status bar, intended for use on dark backgrounds.
    @available(iOS 13.0, *)
    case dark

    /// The underlying `UIStatusBarStyle`.
    var value: UIStatusBarStyle {
        switch self {
        case .default:
            return .default
        case .light:
            return .lightContent
        case .dark:
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
}

/// A basic sheet view that showcases adjusting the status bar style from a SheetViewController's sheet items.
class StatusBarViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .fittingSize,
        supportedPositions: [.fittingSize]
    )

    private static var statusBarStyle: StatusBarStyle = .default

    override var preferredStatusBarStyle: UIStatusBarStyle {
        StatusBarViewController.statusBarStyle.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let segmentedControl = UISegmentedControl(items: StatusBarStyle.allCases.map(String.init(describing:)))
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = StatusBarStyle.allCases.firstIndex(of: StatusBarViewController.statusBarStyle) ?? 0
        segmentedControl.addTarget(self, action: #selector(didSelectStatusBarStyle), for: .valueChanged)
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc func didSelectStatusBarStyle(_ sender: UISegmentedControl) {
        StatusBarViewController.statusBarStyle = StatusBarStyle.allCases[sender.selectedSegmentIndex]
        setNeedsStatusBarAppearanceUpdate()
    }
}
