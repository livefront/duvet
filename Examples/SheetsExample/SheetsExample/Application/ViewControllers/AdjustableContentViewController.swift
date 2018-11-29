import Sheets
import UIKit

class AdjustableViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        supportedPositions: [.open, .half, .closed]
    )
}
