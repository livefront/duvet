import UIKit

/// A `SheetBackgroundView` for the sheet that implements a dimmed background.
///
public class DimmingSheetBackgroundView: SheetBackgroundView {

    // MARK: Initialization

    /// Initialize a `BlurredSheetBackgroundView`.
    ///
    /// - Parameter frame: The view's initial frame.
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)

        alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: SheetBackgroundView

    public override func applyBackground() {
        alpha = 0.5
        backgroundColor = .black
    }

    public override func clearBackground() {
        alpha = 0
    }
}
