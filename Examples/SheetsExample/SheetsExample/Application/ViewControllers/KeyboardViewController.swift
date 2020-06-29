import Sheets
import UIKit

/// A sheet view that displays a text view for user input. The sheet view is sized to fit the
/// content. When the text view becomes the first responder, the position of the sheet is adjusted
/// to account for the size of the keyboard. Corresponds to the "Keyboard - Fitting Size" example.
/// When a sheet view's position is `SheetPosition.fittingSize` the sheet view will handle keyboard
/// management by keeping the contained view above the keyboard.
///
class KeyboardViewController: BaseViewController, ProvidesSheetConfiguration, ProvidesSheetScrollView {
    static let sheetConfiguration = SheetConfiguration(
        dismissKeyboardOnScroll: false,
        initialPosition: .fittingSize,
        supportedPositions: [.fittingSize]
    )

    // MARK: Properties

    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = 4
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var header: SheetHeaderView = {
        let header = SheetHeaderView()
        header.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
        textView.layer.cornerRadius = 10
        return textView
    }()

    lazy var doneButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        constraint.priority = .init(999)
        return constraint
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    var sheetScrollView: UIScrollView {
        return scrollView
    }

    let label: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc laoreet diam eget laoreet pharetra. Vivamus porta lectus in suscipit semper.Integer nec dui quis ante fringilla fermentum. Mauris eros dui, aliquet non eros eu" //, aliquam egestas lorem. Vestibulum euismod, nisi id pellentesque vehicula, neque leo porta neque, rutrum venenatis ante lorem euismod quam. Etiam eget aliquet odio. Mauris eleifend rhoncus augue, ac fringilla magna sodales sit amet. Integer id dictum nibh, at cursus sem. Vivamus ut orci interdum, tempor dolor sed, aliquam erat. Phasellus tincidunt odio diam, vel aliquam leo pellentesque ac. Vestibulum nunc erat, imperdiet id finibus id, tincidunt et quam. Integer bibendum ultrices mauris sit amet dignissim. Etiam malesuada erat neque, sed gravida mauris finibus sed. Fusce et eleifend felis. Quisque viverra viverra ligula non venenatis. Fusce ac leo id quam pulvinar venenatis."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        scrollView.addSubview(textView)
        scrollView.addSubview(label)

        view.addSubview(header)
//        view.addSubview(textView)
//        view.addSubview(label)
        view.addSubview(scrollView)
        view.addSubview(doneButton)

        let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        scrollViewHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.heightAnchor.constraint(equalToConstant: 300),
            scrollViewHeightConstraint,

            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),

            label.topAnchor.constraint(equalTo: textView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),

//            scrollView.contentLayoutGuide.widthAnchor.cons

//            textView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
//            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            label.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
//            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            doneButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButtonBottomConstraint,
            ])
    }

    // MARK: Private

    @objc private func closeButtonTapped() {
        view.endEditing(true)
        coordinator?.dismissSheet()
    }
}
