import Duvet
import UIKit

/// A basic sheet view that can be adjusted between the open, half and closed positions by panning
/// on the view. The background displayed behind the sheet is custom background 
/// Corresponds to the "Blurred Background" example.
///
class CustomBackgroundViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .open,
        supportedPositions: [.open, .half, .closed]
    )
}

/// A `SheetBackgroundView` for the sheet that implements a custom background.
///
class CustomSheetBackgroundView: SheetBackgroundView {
    // MARK: Initialization

    /// Initialize a `CustomSheetBackgroundView`.
    ///
    /// - Parameter frame: The view's initial frame.
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0

        let gradientLayer = layer as? CAGradientLayer
        gradientLayer?.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    // MARK: SheetBackgroundView

    public func applyBackground() {
        alpha = 0.5
    }

    public func clearBackground() {
        alpha = 0
    }
}
