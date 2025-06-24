import WebKit

/* This registry keeps track of the WKWebView instances (and related
 * URLs to open) passed from one scene (opening new tab) to another
 * (the new tab being opened) across requests for scene activations */
final class NavigationRegistry {
    static var shared = NavigationRegistry()

    private var store: [UUID: (url: URL, webView: WKWebView)] = [:]

    /* Register a URL/WKWebView tuple */
    func register(webView: WKWebView, with url: URL, for id: UUID) {
        store[id] = (url, webView)
    }

    /* Adopt a URL/WKWebView tuple */
    func adopt(id: UUID) -> (url: URL, webView: WKWebView)? {
        let view = store[id]
        store[id] = nil
        return view
    }
}
