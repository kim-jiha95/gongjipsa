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

struct HomeView: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()
    @ObservedObject var router = AppRouter.shared

    var body: some View {
        ZStack {
            WebView(url: URL(string: "https://app.gongjipsa.com/auth/signin")!,
                    errorMessage: $errorMessage,
                    viewModel: viewModel)
            .sheet(isPresented: $viewModel.showSafariScreen) {
                SafariView(url: URL(string: viewModel.SafariURL)!)
            }

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

#Preview {
    HomeView()
}
