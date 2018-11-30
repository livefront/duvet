import Sheets
import UIKit

class KeyboardFullViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        initialPosition: .half,
        supportedPositions: [.half, .open]
    )

    // MARK: Properties

    lazy var header: SheetHeaderView = {
        let header = SheetHeaderView()
        header.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
        textView.layer.cornerRadius = 10
        return textView
    }()

    lazy var stackView: UIStackView = {
        let labels: [UILabel] = (1...50).map {
            let label = UILabel()
            label.text = String($0)
            return label
        }

        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        scrollView.addSubview(textView)
        scrollView.addSubview(stackView)

        view.addSubview(header)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),

            stackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustViewForKeyboard(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustViewForKeyboard(notification:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }

    // MARK: Private

    @objc private func closeButtonTapped() {
        view.endEditing(true)
        coordinator?.dismissSheet()
    }

    @objc private func adjustViewForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }

        let keyboardFrameInView = view.convert(keyboardFrameEnd, from: nil)
        let keyboardInScrollView = scrollView.frame.intersection(keyboardFrameInView)

        let animationCurveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveValue ?? UIView.AnimationOptions().rawValue)

        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            let bottomInset = max(keyboardInScrollView.height - self.scrollView.adjustedContentInset.bottom, 0)
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.scrollIndicatorInsets.bottom = bottomInset
        }, completion: nil)
    }
}

extension KeyboardFullViewController: ProvidesSheetScrollView {
    var sheetScrollView: UIScrollView {
        return scrollView
    }
}
