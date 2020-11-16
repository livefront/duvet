import Duvet
import UIKit

/// A sheet view with a scroll view containing content that is larger than the view. The sheet can
/// be adjusted between the open, half and closed positions by panning on the view or in the
/// scroll view. Corresponds to the "Adjustable with Scroll View" example.
///
class AdjustableWithScrollViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        supportedPositions: [.open, .half, .closed]
    )

    // MARK: Properties

    let items = (1...50).map { String($0) }

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

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
}

extension AdjustableWithScrollViewController: UITableViewDataSource {
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
extension AdjustableWithScrollViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelect indexPath=\(indexPath)")
    }
}

extension AdjustableWithScrollViewController: ProvidesSheetScrollView {
    var sheetScrollView: UIScrollView {
        return tableView
    }
}
