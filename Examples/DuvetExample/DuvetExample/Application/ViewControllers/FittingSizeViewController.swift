import Duvet
import UIKit

/// A sheet view that is sized to fit the content of the view. This example just supports the
/// fitting size. Corresponds to the "Fitting Size" example.
///
class FittingSizeViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        initialPosition: .fittingSize,
        supportedPositions: [.fittingSize]
    )

    // MARK: Properties

    /// Label to display text in the view used to demonstate how the sheet can be sized according to
    /// the content in the view.
    let label: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc laoreet diam eget laoreet pharetra. Vivamus porta lectus in suscipit semper. Integer nec dui quis ante fringilla fermentum. Mauris eros dui, aliquet non eros eu, aliquam egestas lorem. Vestibulum euismod, nisi id pellentesque vehicula, neque leo porta neque, rutrum venenatis ante lorem euismod quam. Etiam eget aliquet odio. Mauris eleifend rhoncus augue, ac fringilla magna sodales sit amet. Integer id dictum nibh, at cursus sem. Vivamus ut orci interdum, tempor dolor sed, aliquam erat. Phasellus tincidunt odio diam, vel aliquam leo pellentesque ac. Vestibulum nunc erat, imperdiet id finibus id, tincidunt et quam. Integer bibendum ultrices mauris sit amet dignissim. Etiam malesuada erat neque, sed gravida mauris finibus sed. Fusce et eleifend felis. Quisque viverra viverra ligula non venenatis. Fusce ac leo id quam pulvinar venenatis."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            ])
    }
}
