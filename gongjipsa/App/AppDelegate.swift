//
//  AppDelegate.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/19/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import WebKit
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    let webViewModel = WebViewModel()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // 파이어베이스 설정
        FirebaseApp.configure()

        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()

        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self

        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {

    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        // FCM 토큰을 서버에 전송
        if let token = fcmToken {
            sendFCMTokenToServer(token: token)
        }
    }

    // 서버로 FCM 토큰 전송
    private func sendFCMTokenToServer(token: String) {
        let baseURL = "http://dev-api-gongjipsa.ap-northeast-2.elasticbeanstalk.com/"
        let endpoint = "fcm-token"
        
        guard let url = URL(string: baseURL + endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 쿠키 추가
        if let cookies = HTTPCookieStorage.shared.cookies {
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields = cookieHeaders
        }
        
        let body: [String: Any] = ["token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                // 응답으로 받은 쿠키 저장
                if let fields = httpResponse.allHeaderFields as? [String: String],
                   let url = httpResponse.url {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                    self?.webViewModel.cookies = cookies
                }
            }
        }.resume()
    }
}
