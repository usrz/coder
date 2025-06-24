import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions,
    ) {
        // Get the navigation activity type, if it's not navigation, default init
        guard let activity = connectionOptions.userActivities.first
        else {
            print("🔰 New scene connected (no activity)")
            return
        }

        if (activity.activityType != "com.usrz.coder.navigate") {
            print("🔰 New scene connected (wrong activity type \(activity.activityType))")
            return
        }

        // Get the navigation data, our tuple containing WKWebView and navigation URL
        guard let navigationId = activity.userInfo?["navigationId"] as? UUID,
              let navigationData = NavigationRegistry.shared.adopt(id: navigationId)
        else {
            print("🔰 New scene connected (no navigation data)")
            return
        }

        // We have our navigation data: let's manually create our scene and
        // inject WKWebView and URL to navigate to in the controller manually
        print("🔰 New scene connected (navigation id=\(String(describing: navigationId)))")

        // Get storyboard, instantiate view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CoderViewController") as! CoderViewController
        viewController.navigationWebView = navigationData.webView
        viewController.navigationUrl = navigationData.url

        // Present our new scene
        print("🔰 Presenting window (navigation id=\(String(describing: navigationId)))")
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
