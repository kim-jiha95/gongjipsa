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
        let webView = FullScreenWKWebView()
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
            } else if url.absoluteString == "https://gongjipsa.com/contact" {
                parent.viewModel.showSafariScreen = true
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.fetchCookies(for: webView)
                .sink { cookies in
                    print("Cookies: \(cookies)")
                }
                .store(in: &viewModel.cancellables)
        }

        private func isExternalURL(_ url: URL) -> Bool {
            let externalDomains = ["calendar.google.com", "pf.kakao.com"]
            return externalDomains.contains(url.host ?? "")
        }
    }
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0)
    }
}
