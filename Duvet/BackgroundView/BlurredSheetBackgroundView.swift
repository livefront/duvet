import UIKit

/// A `SheetBackgroundView` for the sheet that implements a blurred background.
///
public class BlurredSheetBackgroundView: SheetBackgroundView {

    // MARK: Properties

    /// The blur effect that is applied to the background.
    let blurEffect = UIBlurEffect(style: .dark)

    /// The visual effect view containing the blur.
    let visualEffectView = UIVisualEffectView()

    // MARK: Initialization

    /// Initialize a `BlurredSheetBackgroundView`.
    ///
    /// - Parameter frame: The view's initial frame.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: SheetBackground

    public func applyBackground() {
        visualEffectView.effect = blurEffect
    }

    public func clearBackground() {
        visualEffectView.effect = nil
    }
}
