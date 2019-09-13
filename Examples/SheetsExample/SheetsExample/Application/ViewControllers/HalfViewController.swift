import Sheets
import UIKit

/// A basic sheet view that can be adjusted between the half and closed positions by panning
/// on the view. Opens in the half position. Corresponds to the "Half Size" example.
///
class HalfViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .half,
        supportedPositions: [.half, .closed]
    )
}
