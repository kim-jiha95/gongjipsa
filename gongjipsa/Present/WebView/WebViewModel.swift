//
//  WebViewModel.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/19/24.
//

import SwiftUI
import WebKit
import Combine

class WebViewModel: ObservableObject {
    @Published var showNativeScreen = false
    @Published var showSafariScreen = false
    @Published var isSignInURL = false
    @Published var cookies: [HTTPCookie] = []

    var cancellables = Set<AnyCancellable>()

    func fetchCookies(for webView: WKWebView) -> Future<[HTTPCookie], Never> {
        return Future { promise in
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                DispatchQueue.main.async {
                    self.cookies = cookies
                    promise(.success(cookies))
                }
            }
        }
    }

    func setCookies(for webView: WKWebView, cookies: [HTTPCookie]) -> Future<Void, Never> {
        return Future { promise in
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            let dispatchGroup = DispatchGroup()

            for cookie in cookies {
                dispatchGroup.enter()
                cookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                promise(.success(()))
            }
        }
    }
}

