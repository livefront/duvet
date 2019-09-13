import Sheets
import UIKit

/// A sheet view that displays a text view for user input. The sheet view is sized to fit the
/// content. When the text view becomes the first responder, the position of the sheet is adjusted
/// to account for the size of the keyboard. Corresponds to the "Keyboard - Fitting Size" example.
/// When a sheet view's position is `SheetPosition.fittingSize` the sheet view will handle keyboard
/// management by keeping the contained view above the keyboard.
///
class KeyboardViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
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

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        view.addSubview(header)
        view.addSubview(textView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            doneButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
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
