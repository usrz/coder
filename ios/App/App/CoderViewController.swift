import Capacitor

class CoderViewController: CAPBridgeViewController, WKUIDelegate {

    override func capacitorDidLoad() {
        print("Capacitor is loaded")
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
        guard let scene = self.view.window?.windowScene
        else { return }

        UIApplication.shared.requestSceneSessionDestruction(
            scene.session,
            options: nil,
            errorHandler: nil
        )
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
}

