//
//  ContentView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 10/11/2024.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    var body: some View {
        if isLoggedIn {
            mainView(isLoggedIn: $isLoggedIn)
        } else {
            loginView(isLoggedIn: $isLoggedIn)
        }
    }
}


#Preview {
    ContentView()
}
