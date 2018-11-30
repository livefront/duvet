import Foundation

/// The enumerations of possible positions that a sheet can be in.
///
/// - closed: The sheet is closed and off-screen.
/// - half: The sheet will be half of the full size.
/// - fittingSize: The sheet will expand to fill the content of the view up to the `open` position.
/// - open: The sheet is expanded to be the full size. In the `open` position, the top of the sheet
///     will be `SheetConfiguration.topInset` points below the top safe area.
///
public enum SheetPosition {
    case closed
    case half
    case fittingSize
    case open
}
