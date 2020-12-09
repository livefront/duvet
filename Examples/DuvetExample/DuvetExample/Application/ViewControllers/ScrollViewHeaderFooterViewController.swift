import Duvet
import UIKit

/// A sheet view that displays content in a scroll view and has a fixed header and footer.
/// Corresponds to the "Scroll View with Header and Footer" example.
///
class ScrollViewHeaderFooterViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        supportedPositions: [.open, .half, .closed]
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

    lazy var footer: UIView = {
        let horizontalRule = UIView()
        horizontalRule.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1)
        horizontalRule.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        horizontalRule.translatesAutoresizingMaskIntoConstraints = false

        let footer = UIView()
        footer.addSubview(doneButton)
        footer.addSubview(horizontalRule)
        footer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalRule.topAnchor.constraint(equalTo: footer.topAnchor),
            horizontalRule.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
            horizontalRule.trailingAnchor.constraint(equalTo: footer.trailingAnchor),

            doneButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 16),
            doneButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -16),
            ])

        return footer
    }()

    lazy var header: SheetHeaderView = {
        let header = SheetHeaderView()
        header.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()

    let items = (1...50).map { String($0) }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        header.titleLabel.text = title

        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(footer)

        let footerBottomConstraint = footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        footerBottomConstraint.priority = .init(999)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            footer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBottomConstraint,
            ])
    }

    // MARK: Private

    @objc private func closeButtonTapped() {
        coordinator?.dismissSheet()
    }
}

extension ScrollViewHeaderFooterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item
        cell.selectionStyle = .none
        return cell
    }
}

extension ScrollViewHeaderFooterViewController: ProvidesSheetScrollView {
    var sheetScrollView: UIScrollView {
        return tableView
    }
}
