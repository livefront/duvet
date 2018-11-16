import Sheets
import UIKit

class BlurredBackgroundViewController: BaseViewController, ProvidesSheetConfiguration {
    static let sheetConfiguration = SheetConfiguration(initialPosition: .open, supportedPositions: [.open, .half, .closed])
}
