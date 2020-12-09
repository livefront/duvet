import UIKit

/// View displayed in a `SheetView` containing the content of the sheet.
///
class SheetContentView: UIView {

    // MARK: Properties

    /// An optional handle for the sheet to indicate that it supports dragging the view up/down.
    var handleView: UIView?

    // MARK: Initialization

    /// Initialize a `SheetContentView`.
    ///
    /// - Parameters:
    ///   - view: The view containing the content of the sheet to display.
    ///   - configuration: The configuration paramaters for the sheet.
    ///
    init(view: UIView, configuration: SheetConfiguration) {
        super.init(frame: .zero)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8

        view.layer.cornerRadius = configuration.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

        if let handleConfiguration = configuration.handleConfiguration {
            let handleView = handleConfiguration.handleView
            self.handleView = handleView

            handleView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(handleView)

            NSLayoutConstraint.activate([
                handleView.topAnchor.constraint(equalTo: topAnchor, constant: -handleConfiguration.topInset),
                handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
                ])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let handleViewPoint = convert(point, to: self)
        if let handleView = handleView, handleView.frame.contains(handleViewPoint) {
            return true
        }

        return super.point(inside: point, with: event)
    }

    // MARK: CALayer

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return super.hitTest(point, with: event) }

        // Extend the handleView's tappable area slightly larger than its small frame.
        if let handleView = handleView, handleView.frame.insetBy(dx: -16, dy: -16).contains(point) {
            return handleView
        }

        return super.hitTest(point, with: event)
    }
}
