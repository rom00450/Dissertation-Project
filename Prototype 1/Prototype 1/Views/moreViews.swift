//
//  moreViews.swift
//  Prototype 1
//
//  Created by Roberto Martin on 13/11/2024.
//
import SwiftUI

struct moreViews: View {
    @Binding var isLoggedIn: Bool  // Bind the `isLoggedIn` state from the parent

    var body: some View {
        NavigationSplitView {
            // Sidebar with navigation options
            List {
                NavigationLink(destination: accountView(isLoggedIn: $isLoggedIn)) {
                    Text("Account")
                }

                NavigationLink(destination: preferencesViews()) {
                    Text("User Preferences")
                }
            }
            .navigationTitle("More")
        } detail: {
            Text("Select an option")  // Placeholder for the detail view
        }
    }
}

#Preview {
    // Provide a default value for the binding for the preview
    moreViews(isLoggedIn: .constant(false))
}

