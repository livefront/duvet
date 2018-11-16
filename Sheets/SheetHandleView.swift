import UIKit

/// A view that represents a handle in a sheet indicating that the view can be dragged up/down.
///
class SheetHandleView: UIView {

    // MARK: Properties

    /// The white rounded handle that is displayed in the view.
    let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: Initialization

    /// Initialize a `SheetHandleView`.
    ///
    /// - Parameter frame: The view's initial frame.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8

        addSubview(handleView)

        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: topAnchor),
            handleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            handleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            handleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
