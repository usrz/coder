import Capacitor

class CoderViewController: CAPBridgeViewController, WKUIDelegate {

    /* Capacitor was loaded, the webview is ready */
    override func capacitorDidLoad() {
        print("🔰 Capacitor did load")
        // Setup ourselves as the UI delegate for the web view so that
        // we can trap when "window.open()" and "window.close()" are
        // called in JavaScript land...
        self.webView?.uiDelegate = self
    }

    /* Called when "window.open(...) is invoked, with our URL */
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures,
    ) -> WKWebView? {
        // Basic checks, we need to have our bridge and a URL to go to
        guard let bridge = bridge, let url = navigationAction.request.url else {
            print("🔰 No Cpacitor bridge or URL to navigate to")
            return nil
        }

        // Create a WKWebView, if we don't return it Coder complains about popups
        let webView = WKWebView(frame: .zero, configuration: configuration)

        // If this one of the hosts we are allowed to navigate to, we'll open a
        // new scene, pass the WKWebView created here, and show it over there..
        if let host = url.host, bridge.config.shouldAllowNavigation(to: host) {
            print("🔰 Opening \(url.absoluteString) in a new scene")

            // Register our new tab request under this UUID
            let webViewId = UUID()
            NavigationRegistry.shared.register(webView: webView, with: url, for: webViewId)

            // Prepare the activity to dispatch
            let userActivity = NSUserActivity(activityType: "com.usrz.coder.navigate")
            let options = UIScene.ActivationRequestOptions()

            userActivity.userInfo = [ "navigationId": webViewId ]
            options.requestingScene = UIApplication.shared.connectedScenes.first

            // Request the activation of a new scene, hopefully it'll pick up the view and URL
            UIApplication.shared.requestSceneSessionActivation(nil,
                    userActivity: userActivity,
                    options: options,
                    errorHandler: { error in
                        print("🔰 Failed to open new window: \(error.localizedDescription)")
            })

        // If this is not one of the nosts we are allowed to navigate to, we'll
        // simply handle it off to the OS. We still return a WKWebView to the
        // caller (Coder will complain about popups otherwise), but immediately
        // close it from JavaScript without navigating (is this needed?)
        } else {
            print("🔰 Opening \(url.absoluteString) in the system browser")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            webView.evaluateJavaScript("window.close()", completionHandler: nil)
        }

        // Return the WKWebView
        return webView
    }

    /* Teardown our scene when the WKWebView was closed (normally "window.close()") */
    func webViewDidClose(_ webView: WKWebView) {
        print("🔰 WKWebView did close")
        self.actuallyCloseWindow()
    }

    /* ===== HANDLING THE "NEW WINDOW" REQUEST FROM ABOVE ====================================== */

    var navigationWebView: WKWebView? = nil
    var navigationUrl: URL? = nil

    /* Inject the WKWebView created (above) in a different scene */
    override func webView(with frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
        print("🔰 NavigationData INSIDE \(String(describing: navigationUrl)) \(String(describing: navigationWebView))")

        guard let webView = navigationWebView else {
            print("🔰 Creating new WKWebView")
            return super.webView(with: frame, configuration: configuration)
        }

        print("🔰 Injecting WKWebView from a different scene")
        navigationWebView = nil
        webView.frame = frame
        return webView
    }

    /* Perform navigation to our URL, if different from the start one */
    override open func viewDidLoad() {
        print("🔰 View did load")

        // This will trigger the immediate navigation to "bridge.config.appStartServerURL"
        // and unfortunately, as "loadWebView()" is final, and there doesn't seem to be a
        // way to dynamically change the "appStartServerURL" at runtime there is not much
        // we can do... Trying to replace the WebViewDelegationHandler is also impossible
        // in the current state of Capacitor so our only option is... HACK!
        super.viewDidLoad()

        // If we don't have a navigation URL, nothing to do..
        guard let url = navigationUrl
        else { return }
        navigationUrl = nil

        // Check if the "appStartServerURL" is different from our navigation one
        if (url == bridge?.config.appStartServerURL) {
            return
        }

        // Stop and immediately restart with our new URL
        print("🔰 Performing initial navigation to \(url.absoluteString)")
        webView?.stopLoading()
        webView?.load(URLRequest(url: url))
    }

    /* ===== HANDLE KEY COMMANDS =============================================================== */

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand( title: "Close Window", action: #selector(handleCloseWindow), input: "W", modifierFlags: [ .command, .shift ]),
            UIKeyCommand( title: "Close Tab",    action: #selector(handleCloseTab),    input: "w", modifierFlags: .command),
            UIKeyCommand( title: "Cancel",       action: #selector(handleCancel),      input: ".", modifierFlags: .command),
        ]
    }

    /* Close the current scene (CMD-SHIFT-W) */
    @objc func handleCloseWindow() {
        print("🔰 Handling CMD-SHIFT-W")
        nicelyCloseWindow()
    }

    /* Forward CMD-W (Close Editor) to JavaScript */
    @objc func handleCloseTab() {
        print("🔰 Handling CMD-W")
        injectKeyCombo(key: "w", code: "KeyW", metaKey: true)
    }

    /* Forward CMD-Period (Cancel) to JavaScript */
    @objc func handleCancel() {
        print("🔰 Handling CMD-Period")
        injectKeyCombo(key: ".", code: "Period", metaKey: true)
    }

    /* Inject a KeyEvent in the current WKWebView */
    func injectKeyCombo(
        key: String,
        code: String,
        metaKey: Bool = false,
        ctrlKey: Bool = false,
        altKey: Bool = false,
        shiftKey: Bool = false,
        sendKeyUp: Bool = true
    ) {
        guard let webView = self.webView else { return }

        let js = """
        (function() {
            if (! document.activeElement) return
            const keyDownEvent = new KeyboardEvent('keydown', {
                key: '\(key)',
                code: '\(code)',
                metaKey: \(metaKey),
                ctrlKey: \(ctrlKey),
                altKey: \(altKey),
                shiftKey: \(shiftKey),
                bubbles: true,
                cancelable: true
            });
            const keyUpEvent = new KeyboardEvent('keyup', {
                key: '\(key)',
                code: '\(code)',
                metaKey: \(metaKey),
                ctrlKey: \(ctrlKey),
                altKey: \(altKey),
                shiftKey: \(shiftKey),
                bubbles: true,
                cancelable: true
            });
            const target = document.activeElement || document.body
            if (! target) return
            target.dispatchEvent(keyDownEvent);
            target.dispatchEvent(keyUpEvent);
        })();
        """

        webView.evaluateJavaScript(js, completionHandler: { result, error in
            if let error = error {
                print("🔰 JS error: \(error)")
            }
        })
    }

    /* ===== WINDOW CLOSING CONFIRMATION ======================================================= */

    /* Ask before closing a window: on iPad it's a quite intensive operation */
    func nicelyCloseWindow() {
        presentConfirmDialog(
            title: "Close Window",
            message: "Are you sure you want to close this window?",
            okTitle: "Close",
            onConfirm: actuallyCloseWindow,
        )
    }

    /* Actually close the window, either from our dialog, or when WKWebView is closed */
    func actuallyCloseWindow() {
        guard let scene = self.view.window?.windowScene
        else { return }

        UIApplication.shared.requestSceneSessionDestruction(
            scene.session,
            options: nil,
            errorHandler: nil
        )
    }

    /* Confirm dialog, we might reuse it someday */
    func presentConfirmDialog(
        title: String,
        message: String,
        okTitle: String = "OK",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { _ in
            onConfirm()
        }))

        self.present(alert, animated: true)
    }
}
