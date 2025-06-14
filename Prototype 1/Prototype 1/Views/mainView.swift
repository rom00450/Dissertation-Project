//
//  mainView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 12/11/2024.
//

import SwiftUI

import SwiftUI

struct mainView: View {
    @Binding var isLoggedIn: Bool  // Bind the `isLoggedIn` state from the parent

    var body: some View {
        TabView {
            scannerView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            chatBotView()
                .tabItem {
                    Label("Chat", systemImage: "ellipsis.message")
                }
            recipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book.pages")
                }
            communityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
            moreViews(isLoggedIn: $isLoggedIn)  // Pass `isLoggedIn` to `moreViews`
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
        }
    }
}

#Preview {
    // Provide a constant binding value for preview purposes
    mainView(isLoggedIn: .constant(true))
}
