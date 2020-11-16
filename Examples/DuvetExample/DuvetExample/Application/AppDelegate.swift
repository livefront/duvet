import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let coordinator = DefaultAppCoordinator()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.rootViewController
        window?.makeKeyAndVisible()

        coordinator.showViewController()

        return true
    }
}
