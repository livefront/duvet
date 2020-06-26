# Sheets

A configurable framework for presenting bottom sheets on iOS.

![Sheets](Docs/Images/sheets.gif)

## Contents

* [Features](#features)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#swift-package-manager)
* [Usage](#usage)
    * [Overview](#overview)
    * [Configuration](#configuration)
    * [Scroll View Interation](#scroll-view-interation)
    * [Pushing/Popping Sheets](#pushingpopping-sheets)
* [Examples](#examples)
* [License](#license)

## Features

* Sheets can be presented in different sizes:
    * Full screen sheets are similar  to `UIModalPresentationPageSheet` on iOS 13+.
    * Half screen sheets.
    * Fitting size sheets are sized to the content displayed, when smaller than a full screen sheet.
* Content in the sheet can be embedded in a scroll view to support scrolling when the content height exceeds that of the sheet.
* Supports panning the sheet between different positions.
* Sheets can be stacked - push additional sheets on and then pop them off.
* Automatically adjusts the sheet when the keyboard appears/disappears.
* Configure display properties like the top inset of a full-screen sheet, optional handle to indicate sheet panning, dimmed background view and more.

| Full Sheet | Half Sheet | Fitting Size Sheet | Fitting Size with a Keyboard |
| --- | --- | --- | --- |
| ![Full Sheet](Docs/Images/full_sheet.png) | ![Half Sheet](Docs/Images/half_sheet.png) | ![Fitting Size Sheet](Docs/Images/fitting_size_sheet.png) | ![Fitting Size with Keyboard](Docs/Images/fitting_size_sheet_with_keyboard.png) | 

## Requirements

* iOS 11+

## Usage

### Overview

1. Import `Sheets` into the file that you will present a sheet from.

    ```swift
    import Sheets
    ```

1. Create a `SheetItem` with the view controller that should will be shown in the sheet.

    ```swift
    let sheetItem = SheetItem(
        viewController: viewController,
        configuration: SheetConfiguration(),
        scrollView: nil
    )
    ```

1. Create a `SheetViewController`. The `SheetViewController` is a container view controller for a stack of sheets, similar to `UINavigationController`. It will allow you to push on and pop off additional `SheetItem`s.

    ```swift
    let sheetViewController = SheetViewController(sheetItem: sheetItem)
    sheetViewController.modalPresentationStyle = .custom

    // Note: `sheetTransitioningDelegate` needs to be retained by the presenting view controller.
    let sheetTransitioningDelegate = SheetTransitioningDelegate()
    sheetViewController.transitioningDelegate = sheetTransitioningDelegate
    ```

1. Conform the presenting view controller to `SheetViewControllerDelegate` to handle dismissing the sheet.

    ```swift
    extension PresentingViewController: SheetViewControllerDelegate {
        func dismissSheetViewController() {
            dismiss(animated: true, completion: nil)
        }
    }
    ```

1. Then the `SheetViewController` can be presented by your presenting view controller.

    ```swift
    <presentingViewController>.present(sheetViewController, animated: true)
    ```

### Configuration

Various parameters can be configured for a sheet via a `SheetConfiguration` when creating a `SheetItem.`

| Property | Description |
| --- | --- |
| `cornerRadius` | The corner radius of the sheet. Defaults to 10. |
| `dismissKeyboardOnScroll` | True if the keyboard should be dismissed when the sheet view's scroll view is scrolled. Defaults to `true`. |
| `handleConfiguration` | An optional configuration for displaying a handle in or above the sheet to indicate that the sheet can be panned. Defaults to `nil` for no handle. |
| `initialPosition` | The initial position of the sheet when presented. Defaults to `.open` for a full sized sheet. |
| `supportedPositions` | The list of positions that the sheet can be adjusted to via panning. Defaults to `[.open]`, which only allows the sheet to be fully sized or closed. |
| `topInset` | The number of points between the top of the sheet and the top safe area. Defaults to 44. |

### Scroll View Interation

If the view controller that you want to show in the sheet has a scroll view that wraps the sheet content, `Sheets` needs to be able to interact with it so that it knows whether you should be scrolling the scroll view or panning the sheet.

For this interaction to occur, pass a reference to your view controller's scroll view when creating the `SheetItem`:

```swift
let sheetItem = SheetItem(
    viewController: viewController,
    configuration: SheetConfiguration(),
    scrollView: viewController.scrollView 
)
```

### Pushing/Popping Sheets

`SheetViewController` supports managing a stack of `SheetItem`s. This allows additional sheets to be pushed on and then popped off of the stack.

1. Display an initial sheet.

    ```swift
    let sheetItem = SheetItem(
        viewController: <view controller for first sheet> 
        configuration: SheetConfiguration(),
        scrollView: nil
    )
    let sheetViewController = SheetViewController(sheetItem: sheetItem)
    sheetViewController.delegate = self
    sheetViewController.modalPresentationStyle = .custom
    sheetViewController.transitioningDelegate = sheetTransitioningDelegate
    present(sheetViewController, animated: true)
    ```

1. Push an additional sheet onto the sheet stack.

    ```swift
    let sheetItem2 = SheetItem(
        viewController: <view controller for first sheet> 
        configuration: SheetConfiguration(),
        scrollView: nil
    )
    sheetViewController.push(sheetItem: sheetItem, animated: true)
    ```

1. Pop that sheet off of the sheet stack.

    ```swift
    sheetViewController.pop(animated: true)
    ```

## Examples

There is an example application showing how to present and configure `Sheets` for many common use cases in the `Example` directory.

![Sheets Example Application](Docs/Images/sheets_example.png)

## License

This library is released under the Apache 2.0 license. See the LICENSE file for details.


