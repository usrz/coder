import Capacitor

class CoderViewController: CAPBridgeViewController, WKUIDelegate {

    /* Capacitor was loaded, the webview is ready */
    override func capacitorDidLoad() {
        print("Capacitor is loaded")
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
            print("No Cpacitor bridge or URL to navigate to")
            return nil
        }

        // Create a WKWebView, if we don't return it Coder complains about popups
        let webView = WKWebView(frame: .zero, configuration: configuration)

        // If this one of the hosts we are allowed to navigate to, we'll open a
        // new scene, pass the WKWebView created here, and show it over there..
        if let host = url.host, bridge.config.shouldAllowNavigation(to: host) {
            print("THIS IS A RIGHT TAB GOING TO \(url.absoluteString)")
            return nil

        // If this is not one of the nosts we are allowed to navigate to, we'll
        // simply handle it off to the OS. We still return a WKWebView to the
        // caller (Coder will complain about popups otherwise), but immediately
        // close it from JavaScript without navigating (is this needed?)
        } else {
            print("Opening \(url.absoluteString) in the system browser")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            webView.evaluateJavaScript("window.close()", completionHandler: nil)
        }

        // Return the WKWebView
        return webView
    }

    /* Teardown our scene when the WKWebView was closed (normally "window.close()") */
    func webViewDidClose(_ webView: WKWebView) {
        print("WKWebView did close")
        self.actuallyCloseWindow()
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
        print("Handling CMD-SHIFT-W")
        nicelyCloseWindow()
    }

    /* Forward CMD-W (Close Editor) to JavaScript */
    @objc func handleCloseTab() {
        print("Handling CMD-W")
        injectKeyCombo(key: "w", code: "KeyW", metaKey: true)
    }

    /* Forward CMD-Period (Cancel) to JavaScript */
    @objc func handleCancel() {
        print("Handling CMD-Period")
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
                print("JS error: \(error)")
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
