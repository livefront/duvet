import UIKit

extension UIGestureRecognizer {

    /// Force a `UIGestureRecognizer` to call the specified action on each of its targets.
    ///
    /// Adapted from:
    /// - https://medium.com/@darjeelingsteve/unit-testing-with-uigesturerecognizer-8342ae1a784e
    /// - https://stackoverflow.com/a/46164887
    ///
    func forceGestureRecognition() {
        guard let gestureRecognizerTarget = NSClassFromString("UIGestureRecognizerTarget"),
            let targetVariable = class_getInstanceVariable(gestureRecognizerTarget, "_target") else {
                return
        }

        if let targets = value(forKey: "_targets") as? [AnyObject] {
            for target in targets {
                guard let targetObject = object_getIvar(target, targetVariable),
                    let selectorString = String(describing: target).components(separatedBy: ", ").first?.replacingOccurrences(of: "(action=", with: "") else {
                        continue
                }

                let selector = Selector(selectorString)
                (targetObject as AnyObject).perform(selector, on: .main, with: nil, waitUntilDone: true)
            }
        }
    }
}
