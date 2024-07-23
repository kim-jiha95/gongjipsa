//
//  HomeView.swift
//  gongjipsa
//
//  Created by Jihaha kim on 2024/06/25.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct HomeViewController: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()
    @ObservedObject var router = AppRouter.shared

    var body: some View {
        ZStack {
            WebViewController(url: URL(string: "https://gongjipsa.com/")!,
                    errorMessage: $errorMessage,
                    viewModel: viewModel)
            .sheet(isPresented: $viewModel.showSafariScreen) {
                SafariView(url: URL(string: "https://gongjipsa.com/contact")!)
            }
            .edgesIgnoringSafeArea(.all)

            if let errorMessage = errorMessage {
                VStack {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct SignInView: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()

    var body: some View {
        ZStack {
            WebViewController(url: URL(string: "https://app.gongjipsa.com/auth/signin")!,
                    errorMessage: $errorMessage,
                    viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)

            if let errorMessage = errorMessage {
                VStack {
                    Text("Error2: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeViewController()
}
