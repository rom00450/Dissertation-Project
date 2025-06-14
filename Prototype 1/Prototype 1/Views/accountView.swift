//
//  accountView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 16/11/2024.
//
import SwiftUI
import FirebaseAuth

struct accountView: View {
    @Binding var isLoggedIn: Bool

    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()

            Text("Welcome to your account!")
                .font(.title)

            Spacer()

            Button("Sign Out") {
                logOut()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}


#Preview {
    accountView(isLoggedIn: .constant(true))
}
