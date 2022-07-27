import Duvet
import UIKit

enum StatusBarStyle: CaseIterable {
    static var allCases: [StatusBarStyle] {
        var styles: [StatusBarStyle] = [.default, .light]
        if #available(iOS 13.0, *) {
            styles.append(.dark)
        }
        return styles
    }

    case `default`
    case light

    @available(iOS 13.0, *)
    case dark

    var label: String {
        switch self {
        case .default: return "Default"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

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

    private var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()

        let segmentedControl = UISegmentedControl(items: StatusBarStyle.allCases.map(\.label))
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(didSelectStatusBarStyle), for: .valueChanged)
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
        ])
    }

    @objc func didSelectStatusBarStyle(_ sender: UISegmentedControl) {
        statusBarStyle = StatusBarStyle.allCases[sender.selectedSegmentIndex].value
    }
}
