import Foundation
import UIKit

#if DEBUG
    func dLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        print("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    }
#else
    func dLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
#endif