import Duvet
import UIKit

/// A basic sheet view that opens in the full position and cannot be adjusted. Corresponds to the
/// "Full Size" example.
///
class FullSizeViewController: BaseViewController, ProvidesSheetConfiguration {
    static var sheetConfiguration = SheetConfiguration()
}
