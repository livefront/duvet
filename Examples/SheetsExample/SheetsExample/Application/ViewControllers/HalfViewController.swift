import Sheets
import UIKit

class HalfViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(initialPosition: .half, supportedPositions: [.half, .closed])
}
