import Sheets
import UIKit

class HalfViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .half,
        supportedPositions: [.half, .closed]
    )
}
