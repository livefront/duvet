import Duvet
import UIKit

protocol AppCoordinator: AnyObject {
    var rootViewController: UIViewController { get }

    func dismissSheet()

    func popSheet()

    func showNextSheet()

    func showSheetViewController(viewControllerType: BaseViewController.Type, backgroundView: SheetBackgroundView, title: String)

    func showViewController()
}

class DefaultAppCoordinator {

    // MARK: Properites

    private let navigationController: UINavigationController = StatusBarNavigationController()

    private let sheetTransitioningDelegate = SheetTransitioningDelegate()   // swiftlint:disable:this weak_delegate
}

// MARK: - AppCoordinator

extension DefaultAppCoordinator: AppCoordinator {
    var rootViewController: UIViewController {
        return navigationController
    }

    func dismissSheet() {
        navigationController.dismiss(animated: true)
    }

    func popSheet() {
        guard let sheetViewController = navigationController.presentedViewController as? SheetViewController else {
            return
        }
        sheetViewController.pop(animated: true)
    }

    func showNextSheet() {
        guard let sheetViewController = navigationController.presentedViewController as? SheetViewController else { return }

        let viewController = PushPopViewController()
        let configuration = PushPopViewController.sheetConfiguration
        let sheetItem = SheetItem(viewController: viewController, configuration: configuration, scrollView: nil)

        viewController.title = String(sheetViewController.sheetItems.count)

        viewController.coordinator = self

        sheetViewController.push(sheetItem: sheetItem, animated: true)
    }

    func showSheetViewController(viewControllerType: BaseViewController.Type, backgroundView: SheetBackgroundView, title: String) {
        let viewController = viewControllerType.init()
        viewController.coordinator = self
        viewController.title = title

        let configuration = (viewControllerType as? ProvidesSheetConfiguration.Type)?.sheetConfiguration ?? SheetConfiguration()
        let scrollView = (viewController as? ProvidesSheetScrollView)?.sheetScrollView
        let sheetItem = SheetItem(viewController: viewController, configuration: configuration, scrollView: scrollView)

        let sheetViewController = SheetViewController(sheetItem: sheetItem, backgroundView: backgroundView)
        sheetViewController.delegate = self
        sheetViewController.modalPresentationStyle = .custom
        sheetViewController.transitioningDelegate = sheetTransitioningDelegate

        navigationController.present(sheetViewController, animated: true)
    }

    func showViewController() {
        let viewController = ViewController()
        viewController.coordinator = self

        navigationController.viewControllers = [viewController]
    }
}

// MARK: - SheetViewControllerDelegate

extension DefaultAppCoordinator: SheetViewControllerDelegate {
    func dismissSheetViewController() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.navigationController.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
