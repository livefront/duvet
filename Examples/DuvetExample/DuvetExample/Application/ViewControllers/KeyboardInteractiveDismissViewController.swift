import Duvet
import UIKit

// MARK: - KeyboardInteractiveDismissViewController

/// A sheet view that displays a text view for user input. The sheet view is sized to fit the
/// content. When the text view becomes the first responder, the bottom of the sheet is adjusted to
/// account for the size of the keyboard. This example utilizes the optional configuration property
/// `keyboardBackgroundColor` to display a background view behind the keyboard that has the color
/// provided.
class KeyboardInteractiveDismissViewController: BaseViewController, ProvidesSheetConfiguration {
    static var sheetConfiguration: SheetConfiguration = SheetConfiguration(
        initialPosition: .fittingSize,
        keyboardBackgroundColor: .white,
        supportedPositions: [.fittingSize])

    // MARK: Properties

    /// The done button at the bottom of the view.
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = 4
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    /// The header displayed above the text view.
    lazy var header: SheetHeaderView = {
        let header = SheetHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return header
    }()

    /// A view used to wrap the content of the scroll view.
    lazy private var scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
        return view
    }()

    /// The scroll view used to make the textfield scrollable.
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.addSubview(scrollContentView)
        NSLayoutConstraint.activate([
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
        return scrollView
    }()

    /// The text view used to accept user input.
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        textView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
        textView.layer.cornerRadius = 10
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 17)
        textView.text = "This is some initial scrollable text. Tap to edit to see how the keyboard interacts with this view."
        return textView
    }()

    /// A constraint used to ensure that the scroll view takes up all the available vertical space.
    lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        // allows the scroll view to take up the maximum amount of vertical space without going off screen
        let constraint = scrollView.heightAnchor.constraint(equalTo: scrollContentView.heightAnchor)
        constraint.priority = .init(999)
        return constraint
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        view.addSubview(scrollView)
        view.addSubview(header)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollViewHeightConstraint,

            doneButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    // MARK: Private Methods

    /// A hander for the close button being tapped.
    @objc private func closeButtonTapped() {
        view.endEditing(true)
        coordinator?.dismissSheet()
    }
}
