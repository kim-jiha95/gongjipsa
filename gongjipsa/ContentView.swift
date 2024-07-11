//
//  ContentView.swift
//  gongjipsa
//
//  Created by Jihaha kim on 2024/06/25.
//

import SwiftUI

struct ContentView: View {
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: URL(string: "https://gongjipsa.com/")!,
                        errorMessage: $errorMessage)
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
}

#Preview {
    ContentView()
}
