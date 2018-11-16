import Sheets
import UIKit

class AdjustableViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(supportedPositions: [.open, .half, .closed])
}
