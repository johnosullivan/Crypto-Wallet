import UIKit

public class PopupWindowManager {
    public var popupContainerWindow: PopupContainerWindow?
    public static let shared = PopupWindowManager()

    public func changeKeyWindow(rootViewController: UIViewController?) {
        if let rootViewController = rootViewController {
            popupContainerWindow = PopupContainerWindow()
            guard let popupContainerWindow = popupContainerWindow, rootViewController is BasePopupViewController else { return }
            popupContainerWindow.frame = UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
            popupContainerWindow.backgroundColor = .clear
            popupContainerWindow.windowLevel = UIWindowLevelStatusBar + 1
            popupContainerWindow.rootViewController = rootViewController
            popupContainerWindow.makeKeyAndVisible()
        } else {
            popupContainerWindow?.rootViewController = nil
            popupContainerWindow = nil
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
}
