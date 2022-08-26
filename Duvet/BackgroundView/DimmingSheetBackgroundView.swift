import UIKit

/// A `SheetBackgroundView` for the sheet that implements a dimmed background.
///
public class DimmingSheetBackgroundView: SheetBackgroundView {

    /// The alpha of the view when it is applied (dimmed). Defaults to 0.5.
    public var alphaWhenDimmed = 0.5

    // MARK: Initialization

    /// Initialize a `DimmingSheetBackgroundView`.
    ///
    /// - Parameter frame: The view's initial frame.
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: SheetBackground

    public func applyBackground() {
        alpha = alphaWhenDimmed
    }

    public func clearBackground() {
        alpha = 0
    }
}
