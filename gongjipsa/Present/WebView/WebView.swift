//
//  WebView.swift
//  gongjipsa
//
//  Created by Jihaha kim on 2024/06/25.
//

import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var errorMessage: String?
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.addUserScript(script)
        let conf = WKWebViewConfiguration()
        conf.userContentController = userContentController
        let webView = FullScreenWKWebView(frame: .zero, configuration: conf)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        if !viewModel.cookies.isEmpty {
            viewModel.setCookies(for: webView, cookies: viewModel.cookies)
                .sink { _ in
                    webView.load(URLRequest(url: url))
                }
                .store(in: &viewModel.cancellables)
        } else {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var viewModel: WebViewModel
        
        init(_ parent: WebView, viewModel: WebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed navigation with error: \(error)")
            parent.errorMessage = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled {
                return
            }
            print("Failed provisional navigation with error: \(error)")
            parent.errorMessage = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if isExternalURL(url) || url.scheme == "webcal" || url.absoluteString == "https://app.gongjipsa.com/reservations/all" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
            else if isSafariURL(url) {
                parent.viewModel.showSafariScreen = true
                parent.viewModel.SafariURL = url.absoluteString
                decisionHandler(.cancel)
            }
            else {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.fetchCookies(for: webView)
                .sink { cookies in
                    //                    print("Cookies: \(cookies)")
                }
                .store(in: &viewModel.cancellables)
        }
        private func isExternalURL(_ url: URL) -> Bool {
            let externalDomains = ["calendar.google.com", "pf.kakao.com"]
            return externalDomains.contains(url.host ?? "")
        }
        
        private func isSafariURL(_ url: URL) -> Bool {
            let safariPaths = [
                "https://gongjipsa.com/contact",
                "https://gongjipsa.com/pricing",
                "https://forms.gle/uDmBmpYzdYm3BBMb9",
                "https://app.gongjipsa.com/account/plan-change"
            ]
            return safariPaths.contains(url.absoluteString)
        }
    }
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return .zero
    }
}
