import UIKit

public typealias SheetBackgroundView = SheetBackground & UIView

public protocol SheetBackground: AnyObject {
    /// Apply the background in the view. This will be called in an animation block when the
    /// background should be shown.
    func applyBackground()

    /// Clear the background from the view. This will be called in an animation block when the
    /// background should be hidden.
    func clearBackground()
}
