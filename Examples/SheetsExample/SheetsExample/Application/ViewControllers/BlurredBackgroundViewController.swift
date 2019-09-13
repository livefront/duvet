import Sheets
import UIKit

/// A basic sheet view that can be adjusted between the open, half and closed positions by panning
/// on the view. The background displayed behind the sheet is blurred instead of dimmed.
/// Corresponds to the "Blurred Background" example.
///
class BlurredBackgroundViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .open,
        supportedPositions: [.open, .half, .closed]
    )
}
