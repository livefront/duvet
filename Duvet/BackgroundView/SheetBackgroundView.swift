import UIKit

/// Base class for a background view that can be applied behind the sheet. This should be overriden
/// to apply and clear the desired background when requested.
///
public class SheetBackgroundView: UIView {

    /// Apply the background in the view. This will be called in an animation block when the
    /// background should be shown.
    public func applyBackground() {}

    /// Clear the background from the view. This will be called in an animation block when the
    /// background should be hidden.
    public func clearBackground() {}
}
