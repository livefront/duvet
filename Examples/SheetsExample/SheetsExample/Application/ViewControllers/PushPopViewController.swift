import Sheets
import UIKit

/// A sheet view that allows pushing new sheets onto a stack of sheet views and then popping them
/// off of the stack, similar to how `UINavigationController` manages a stack of view controllers.
/// Corresponds to the "Push/Pop" example.
///
class PushPopViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(supportedPositions: [.open, .half, .closed])

    // MARK: Properties

    lazy var header: SheetHeaderView = {
        let header = SheetHeaderView()
        header.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = 4
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        view.addSubview(header)
        view.addSubview(nextButton)

        let nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        nextButtonBottomConstraint.priority = .init(999)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            nextButton.topAnchor.constraint(greaterThanOrEqualTo: header.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nextButtonBottomConstraint,
            ])
    }

    // MARK: Private

    @objc private func closeButtonTapped() {
        coordinator?.popSheet()
    }

    @objc private func nextButtonTapped() {
        coordinator?.showNextSheet()
    }
}
