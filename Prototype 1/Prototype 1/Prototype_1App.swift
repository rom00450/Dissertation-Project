//
//  Prototype_1App.swift
//  Prototype 1
//
//  Created by Roberto Martin on 10/11/2024.
//

import SwiftUI
import Firebase

@main
struct Prototype_1App: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



