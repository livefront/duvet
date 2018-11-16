import UIKit

class SheetHeaderView: UIView {

    // MARK: Properties

    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "close-circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    let horizontalRule: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1)
        view.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(horizontalRule)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            horizontalRule.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalRule.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            horizontalRule.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

