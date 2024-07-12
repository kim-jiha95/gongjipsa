//
//  ContentView.swift
//  gongjipsa
//
//  Created by Jihaha kim on 2024/06/25.
//


import SwiftUI

struct ContentView: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: URL(string: "https://gongjipsa.com/")!,
                        errorMessage: $errorMessage,
                        viewModel: viewModel)
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

                NavigationLink(destination: AppView(), isActive: $viewModel.isSignInURL) {
                    EmptyView()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct AppView: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()
    
    var body: some View {
        ZStack {
            WebView(url: URL(string: "https://app.gongjipsa.com")!,
                    errorMessage: $errorMessage,
                    viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
            
            if let errorMessage = errorMessage {
                VStack {
                    Text("Error1: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding()
            }
            NavigationLink(destination: SignInView(), isActive: $viewModel.isSignInURL) {
                EmptyView()
            }
        }
    }
}

struct SignInView: View {
    @State private var errorMessage: String?
    @ObservedObject var viewModel = WebViewModel()
    
    var body: some View {
        ZStack {
            WebView(url: URL(string: "https://app.gongjipsa.com/auth/signin")!,
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
    ContentView()
}
