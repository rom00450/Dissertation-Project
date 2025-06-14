//
//  chatBotView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 13/11/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct chatBotView: View {
    @State private var messages: [Message] = [
        Message(content: "Hi! How can I help you today?", isUser: false)
    ]
    @State private var userInput: String = ""
    @State private var userPreferences: [String: Any] = [:] // Store user preferences
    @State private var isLoadingPreferences = true          // Loading state for preferences
    private let chatbot = CohereChatbot()
    let db = Firestore.firestore()
    let userId: String = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        VStack {
            if isLoadingPreferences {
                ProgressView("Loading user preferences...")
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer()
                                        Text(message.content)
                                            .padding()
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(10)
                                            .frame(maxWidth: 250, alignment: .trailing)
                                    } else {
                                        Text(message.content)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                            .frame(maxWidth: 250, alignment: .leading)
                                        Spacer()
                                    }
                                }
                                .padding(message.isUser ? .trailing : .leading, 10)
                                .padding(.vertical, 2)
                                .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack {
                    TextField("Enter your message", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button("Send") {
                        sendMessage()
                    }
                    .padding(.trailing)
                }
            }
        }
        .padding()
        .onAppear(perform: fetchPreferences)
    }

    private func sendMessage() {
        let userMessage = userInput
        messages.append(Message(content: userMessage, isUser: true))
        userInput = ""

        chatbot.sendMessage(prompt: userMessage, userPreferences: userPreferences) { response in
            guard let response = response else {
                DispatchQueue.main.async {
                    messages.append(Message(content: "Sorry, something went wrong.", isUser: false))
                }
                return
            }

            DispatchQueue.main.async {
                messages.append(Message(content: response, isUser: false))
            }
        }
    }

    private func fetchPreferences() {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error loading preferences: \(error.localizedDescription)")
                self.isLoadingPreferences = false
            } else if let data = snapshot?.data() {
                self.userPreferences = data
                self.isLoadingPreferences = false
            } else {
                print("No preferences found.")
                self.isLoadingPreferences = false
            }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

#Preview {
    chatBotView()
}
