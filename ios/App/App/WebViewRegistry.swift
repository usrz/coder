import WebKit

/* This registry keeps track of the WKWebView instances (and related
 * URLs to open) passed from one scene (opening new tab) to another
 * (the new tab being opened) across requests for scene activations */
final class WebViewRegistry {
    static var shared = WebViewRegistry()

    private var store: [UUID: (URL, WKWebView)] = [:]

    /* Register a URL/WKWebView tuple */
    func register(webView: WKWebView, with url: URL, for id: UUID) {
        store[id] = (url, webView)
    }

    /* Adopt a URL/WKWebView tuple */
    func adopt(id: UUID) -> (URL, WKWebView)? {
        let view = store[id]
        store[id] = nil
        return view
    }
}
