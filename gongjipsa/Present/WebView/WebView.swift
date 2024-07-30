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

//    func makeUIView(context: Context) -> WKWebView {
//        let webView = FullScreenWKWebView()
//        webView.navigationDelegate = context.coordinator
//        webView.allowsBackForwardNavigationGestures = true
//        webView.allowsLinkPreview = true
//
//        if !viewModel.cookies.isEmpty {
//            viewModel.setCookies(for: webView, cookies: viewModel.cookies)
//                .sink { _ in
//                    webView.load(URLRequest(url: url))
//                }
//                .store(in: &viewModel.cancellables)
//        } else {
//            webView.load(URLRequest(url: url))
//        }
//
//        return webView
//    }
    func makeUIView(context: Context) -> WKWebView {
        let webView = FullScreenWKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "linkClicked") // 메시지 핸들러 추가

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
            parent.errorMessage = error.localizedDescription
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.errorMessage = error.localizedDescription
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            if isExternalURL(url) || url.scheme == "webcal" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else if isSafariURL(url) {
                parent.viewModel.showSafariScreen = true
                parent.viewModel.SafariURL = url.absoluteString
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.fetchCookies(for: webView)
                .sink { cookies in
//                    print("Cookies: \(cookies)")
                }
                .store(in: &viewModel.cancellables)
            let js = """
                document.querySelectorAll('a, button').forEach(item => {
                    item.addEventListener('click', function(event) {
                        event.preventDefault();
                        window.webkit.messageHandlers.linkClicked.postMessage(this.getAttribute('href') || this.getAttribute('data-url'));
                    });
                });
                """
                webView.evaluateJavaScript(js, completionHandler: nil)
        }

        private func isExternalURL(_ url: URL) -> Bool {
            let externalDomains = ["calendar.google.com", "pf.kakao.com"]
            return externalDomains.contains(url.host ?? "")
        }
       
        private func isSafariURL(_ url: URL) -> Bool {
            let safariPaths = [
                "https://gongjipsa.com/contact",
                "https://gongjipsa.com/pricing",
                "https://forms.gle/uDmBmpYzdYm3BBMb9"
            ]
            return safariPaths.contains(url.absoluteString)
        }
    }
}

extension WebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "linkClicked", let urlString = message.body as? String, let url = URL(string: urlString) {
            if isExternalURL(url)  {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.parent.viewModel.showSafariScreen = true
                self.parent.viewModel.SafariURL = url.absoluteString
            }
        }
    }
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
//        return UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0)
        return .zero
    }
}
