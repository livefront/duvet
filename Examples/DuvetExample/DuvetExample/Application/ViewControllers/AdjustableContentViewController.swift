import Duvet
import UIKit

/// A basic sheet view that can be adjusted between the open, half and closed positions by panning
/// on the view. Corresponds to the "Adjustable" example.
///
class AdjustableViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        supportedPositions: [.open, .half, .closed]
    )
}
