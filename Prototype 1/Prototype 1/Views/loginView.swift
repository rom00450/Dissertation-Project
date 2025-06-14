//
//  loginView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 12/11/2024.
//

import SwiftUI
import FirebaseAuth

struct loginView: View {
    @State private var username = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isError = false

    // Function to register a user
    func register() {
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
            if let error = error {
                alertMessage = "Registration failed: \(error.localizedDescription)"
                isError = true
                showAlert = true
            } else {
                alertMessage = "Registration successful! You can now log in."
                isError = false
                showAlert = true
            }
        }
    }

    // Function to log in a user
    func login() {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                alertMessage = "Login failed: \(error.localizedDescription)"
                isError = true
                showAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }

    func guestLogIn() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                alertMessage = "Login failed: \(error.localizedDescription)"
                isError = true
                showAlert = true
            } else {
                isLoggedIn = true
            }
        }
    }

    var body: some View {
        VStack {
            Text("Fitness and Nutrition App")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Register") {
                register()
            }
            .padding()

            Button("Log in") {
                login()
            }
            .buttonStyle(.bordered)
            .padding()

            Button("Guest Log in") {
                guestLogIn()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isError ? "Error" : "Success"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}


#Preview {
    // Provide a default value for the binding
    loginView(isLoggedIn: .constant(false))
}
