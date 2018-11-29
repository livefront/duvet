import Sheets
import UIKit

class BlurredBackgroundViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(
        handleConfiguration: SheetHandleConfiguration(),
        initialPosition: .open,
        supportedPositions: [.open, .half, .closed]
    )
}
