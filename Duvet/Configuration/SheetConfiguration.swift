import UIKit

/// Configuration parameters for controlling how the sheet view is displayed.
///
public struct SheetConfiguration: Equatable {

    // MARK: Properties

    /// The corner radius of the sheet.
    public var cornerRadius: CGFloat

    /// True if the keyboard should be dismissed when the sheet view's scroll view is scrolled or
    /// false otherwise.
    public var dismissKeyboardOnScroll: Bool

    /// Configuration parameters for displaying a sheet's handle.
    public var handleConfiguration: SheetHandleConfiguration?

    /// The sheets initial position.
    public var initialPosition: SheetPosition

    /// The color of the optional keyboard shim. If no value is provided the keyboard shim is not
    /// displayed.
    public var keyboardBackgroundColor: UIColor?

    /// The list of positions that the view is allowed to adjusted to via panning the view.
    public var supportedPositions: [SheetPosition]

    /// The number of points that the sheet should sit below the top safe area.
    public var topInset: CGFloat

    // MARK: Initialization

    /// Initialize a `SheetConfiguration`.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the sheet.
    ///   - dismissKeyboardOnScroll: True if the keyboard should be dismissed when the sheet view's
    ///     scroll view is scrolled or false otherwise.
    ///   - handleConfiguration: Configuration parameters for displaying a sheet handle.
    ///   - initialPosition: The sheets initial position.
    ///   - keyboardBackgroundColor: An optional color for a shim view that appears behind the
    ///     keyboard when it is presented. This prevents interactive dismissing of the keyboard
    ///     showing the background view while the keyboard is being dragged down.
    ///   - supportedPositions: The list of positions that the view is allowed to be adjusted to via
    ///     panning the view.
    ///   - topInset: The number of points that the sheet should sit below the top safe area.
    ///
    public init(
        // NOTE: If a default value is changed here, be sure to update the Configuration section
        // in the README!
        cornerRadius: CGFloat = 10,
        dismissKeyboardOnScroll: Bool = true,
        handleConfiguration: SheetHandleConfiguration? = nil,
        initialPosition: SheetPosition = .open,
        keyboardBackgroundColor: UIColor? = nil,
        supportedPositions: [SheetPosition] = [.open],
        topInset: CGFloat = 44
    ) {
        self.cornerRadius = cornerRadius
        self.dismissKeyboardOnScroll = dismissKeyboardOnScroll
        self.handleConfiguration = handleConfiguration
        self.initialPosition = initialPosition
        self.keyboardBackgroundColor = keyboardBackgroundColor
        self.supportedPositions = supportedPositions
        self.topInset = topInset
    }
}
