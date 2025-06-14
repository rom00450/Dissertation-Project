//
//  chatBotFunctionality.swift
//  Prototype 1
//
//  Created by Roberto Martin on 26/11/2024.
//

//import Foundation
//
//struct CohereRequest: Encodable {
//    let model: String
//    let prompt: String
//    let max_tokens: Int
//    let temperature: Double
//    let return_likelihoods: String? // Optional, specific to v2 (e.g., "NONE" or "GENERATION")
//}
//
//struct CohereResponse: Decodable {
//    let generations: [Generation]
//    
//    struct Generation: Decodable {
//        let text: String
//    }
//}
//
//class CohereChatbot {
//    private let apiKey = "4CEaD1iE36uuJgPj8nLO6Ord6svTnz05nyeQIPZj" //Standard command model
//    //private let apiKey = "DQQOiX2uNQB5vm2dIurVvNPDShOoGbFBlDWO2nkt" //trained model API
//    //private let endpoint = "https://api.cohere.ai/v2/generate"
//    private let endpoint = "https://api.cohere.ai/v1/chat"
//
//    
//    func sendMessage(prompt: String, userPreferences: [String: Any], completion: @escaping (String?) -> Void) {
//        guard let url = URL(string: endpoint) else {
//            print("Error: Invalid URL")
//            completion(nil)
//            return
//        }
//        
//        // Enrich prompt with user preferences
//        var enrichedPrompt = "## Instructions \n Answer the following user question about fitness and nutrition by giving precise personalised recommendations and exact numbers \n\n"
//        
//        enrichedPrompt += "## Activity level definitions: \n - **Sedentary**: Minimal exercise, mostly desk job or very little movement \n - **Lightly Active**: Light exercise 1-3 times a week (e.g., casual walking, yoga) \n - **Moderately Active**: Regular exercise 3-5 times a week (e.g., gym workouts, running) \n - **Highly Active**: Intense exercise 6+ times a week or a physically demanding job \n\n"
//        
//        
//       enrichedPrompt += "## User Preferences: \n"
//        
//       
//        
//
//        if let gender = userPreferences["gender"] as? String, !gender.isEmpty {
//            enrichedPrompt += "- **Gender**: \(gender)\n"
//        }
////
//        if let age = userPreferences["age"] as? Int {
//            enrichedPrompt += "- **Age**: \(age)\n"
//        }
////
////        if let dietaryPreference = userPreferences["dietaryPreference"] as? String, !dietaryPreference.isEmpty {
////            enrichedPrompt += "- **Dietary Preference**: \(dietaryPreference)\n"
////        }
////
//        if let bodyWeight = userPreferences["weight (kg)"] as? Int {
//            enrichedPrompt += "- **Weight (kg)**: \(bodyWeight)\n"
//        }
//
//        if let goalBodyWeight = userPreferences["goalWeight (kg)"] as? Int {
//            enrichedPrompt += "- **Goal Weight (kg)**: \(goalBodyWeight)\n"
//        }
//
//        if let height = userPreferences["height (cm)"] as? Int {
//            enrichedPrompt += "- **Height (cm)**: \(height)\n"
//        }
//
//        if let fitnessGoal = userPreferences["fitnessGoal"] as? String, !fitnessGoal.isEmpty {
//            enrichedPrompt += "- **Fitness Goal**: \(fitnessGoal)\n"
//        }
//
//        if let activityLevel = userPreferences["activityLevel"] as? String, !activityLevel.isEmpty {
//            enrichedPrompt += "- **Activity Level**: \(activityLevel)\n"
//        }
////
////        if let allergies = userPreferences["allergies"] as? [String], !allergies.isEmpty {
////            enrichedPrompt += "- **Allergies**: \(allergies.joined(separator: ", "))\n"
////        }
////
////        if let dislikedFoods = userPreferences["dislikedFoods"] as? [String], !dislikedFoods.isEmpty {
////            enrichedPrompt += "- **Disliked Foods**: \(dislikedFoods.joined(separator: ", "))\n"
////        }
////
//        if let extraInformation = userPreferences["extraInformation"] as? [String], !extraInformation.isEmpty {
//            enrichedPrompt += "- **Extra Information**: \(extraInformation)\n"
//        }
////
//        enrichedPrompt += "\n ##User Message: \(prompt)"
//
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//
////        let requestBody = CohereRequest(model: "command",
////                                        prompt: enrichedPrompt,
////                                        max_tokens: 800,
////                                        temperature: 0.1,
////                                        return_likelihoods: "NONE") // Adjust if likelihoods are needed
//        
//        let requestBody = CohereRequest(model: "bfddfb01-d7c6-4a02-8b25-4d5c3f6136ac-ft",   //Trained model
//                                        prompt: enrichedPrompt,
//                                        max_tokens: 800,
//                                        temperature: 0.1,
//                                        return_likelihoods: "NONE") // Adjust if likelihoods are needed
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//            print(requestBody)
//        } catch {
//            print("Error encoding request body: \(error)")
//            completion(nil)
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                
//                print("Error: \(String(describing: error))")
//                completion(nil)
//                return
//            }
//            
//            do {
//                let decodedResponse = try JSONDecoder().decode(CohereResponse.self, from: data)
//                if let firstGeneration = decodedResponse.generations.first {
//                    print(firstGeneration.text)
//                    completion(firstGeneration.text)
//                } else {
//                    print("Error: No generations received")
//                    completion(nil)
//                }
//            } catch {
//                print("Decoding error: \(error)")
//                completion(nil)
//            }
//        }.resume()
//    }
//}
//


//import Foundation
//
//// MARK: - Response Models
//struct CohereChatRequest: Encodable {
//    let model: String
//    let message: String
//    let max_tokens: Int
//    let temperature: Double
//    let seed: Int
//}
//
//struct CohereChatResponse: Decodable {
//    let text: String
//}
//
//// MARK: - Cohere Chatbot Class
//class CohereChatbot {
//    private let apiKey = "DQQOiX2uNQB5vm2dIurVvNPDShOoGbFBlDWO2nkt"
//    private let endpoint = "https://api.cohere.ai/v1/chat"
//
//    // Function to send a message and receive a response
//    func sendMessage(prompt: String, userPreferences: [String: Any], completion: @escaping (String?) -> Void) {
//        guard let url = URL(string: endpoint) else {
//            print("Error: Invalid URL")
//            completion(nil)
//            return
//        }
//
//        // Construct user preferences for context
//        var enrichedMessage = "## User Preferences:\n"
//        
//        if let gender = userPreferences["gender"] as? String, !gender.isEmpty {
//            enrichedMessage += "- **Gender**: \(gender)\n"
//        }
//        if let age = userPreferences["age"] as? Int {
//            enrichedMessage += "- **Age**: \(age)\n"
//        }
//        if let bodyWeight = userPreferences["weight (kg)"] as? Int {
//            enrichedMessage += "- **Weight (kg)**: \(bodyWeight)\n"
//        }
//        if let goalBodyWeight = userPreferences["goalWeight (kg)"] as? Int {
//            enrichedMessage += "- **Goal Weight (kg)**: \(goalBodyWeight)\n"
//        }
//        if let height = userPreferences["height (cm)"] as? Int {
//            enrichedMessage += "- **Height (cm)**: \(height)\n"
//        }
//        if let fitnessGoal = userPreferences["fitnessGoal"] as? String, !fitnessGoal.isEmpty {
//            enrichedMessage += "- **Fitness Goal**: \(fitnessGoal)\n"
//        }
//        if let activityLevel = userPreferences["activityLevel"] as? String, !activityLevel.isEmpty {
//            enrichedMessage += "- **Activity Level**: \(activityLevel)\n"
//        }
//        if let extraInformation = userPreferences["extraInformation"] as? [String], !extraInformation.isEmpty {
//            enrichedMessage += "- **Extra Information**: \(extraInformation.joined(separator: ", "))\n"
//        }
//
//        enrichedMessage += "\n## User Message: \(prompt)"
//
//        // Prepare the request body
//        let requestBody = CohereChatRequest(
//            model: "bfddfb01-d7c6-4a02-8b25-4d5c3f6136ac-ft", // Your fine-tuned model ID
//            message: enrichedMessage,
//            max_tokens: 800,
//            temperature: 0.05,
//            seed: 42
//        )
//
//        do {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//            request.httpBody = try JSONEncoder().encode(requestBody)
//            print(requestBody)
//            
//
//            // Perform the API request
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data, error == nil else {
//                    print("Error: \(String(describing: error))")
//                    completion(nil)
//                    return
//                }
//
//                do {
//                    let decodedResponse = try JSONDecoder().decode(CohereChatResponse.self, from: data)
//                    completion(decodedResponse.text)
//                    print(decodedResponse)
//                } catch {
//                    print("Decoding error: \(error)")
//                    completion(nil)
//                }
//            }.resume()
//        } catch {
//            print("Error encoding request body: \(error)")
//            completion(nil)
//        }
//    }
//}















//
//
//


import Foundation

// MARK: - Response Models
struct CohereChatRequest: Encodable {
    let model: String
    let message: String
    let max_tokens: Int
    let temperature: Double
    //let seed: Int
}

struct CohereChatResponse: Decodable {
    let text: String
}

// MARK: - Cohere Chatbot Class
class CohereChatbot {
    private let apiKey = "DQQOiX2uNQB5vm2dIurVvNPDShOoGbFBlDWO2nkt"
    private let endpoint = "https://api.cohere.ai/v1/chat"
    
    // Function to send a message and receive a response
    func sendMessage(prompt: String, userPreferences: [String: Any], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Error: Invalid URL")
            completion(nil)
            return
        }

        // Construct user preferences for context
        var enrichedMessage = "## User Preferences:\n"
        
        if let gender = userPreferences["gender"] as? String, !gender.isEmpty {
            enrichedMessage += "- **Gender**: \(gender)\n"
        }
        if let age = userPreferences["age"] as? Int {
            enrichedMessage += "- **Age**: \(age)\n"
        }
        if let bodyWeight = userPreferences["weight (kg)"] as? Int {
            enrichedMessage += "- **Weight (kg)**: \(bodyWeight)\n"
        }
        if let goalBodyWeight = userPreferences["goalWeight (kg)"] as? Int {
            enrichedMessage += "- **Goal Weight (kg)**: \(goalBodyWeight)\n"
        }
        if let height = userPreferences["height (cm)"] as? Int {
            enrichedMessage += "- **Height (cm)**: \(height)\n"
        }
        if let fitnessGoal = userPreferences["fitnessGoal"] as? String, !fitnessGoal.isEmpty {
            enrichedMessage += "- **Fitness Goal**: \(fitnessGoal)\n"
        }
        if let activityLevel = userPreferences["activityLevel"] as? String, !activityLevel.isEmpty {
            enrichedMessage += "- **Activity Level**: \(activityLevel)\n"
        }
        if let extraInformation = userPreferences["extraInformation"] as? [String], !extraInformation.isEmpty {
            enrichedMessage += "- **Extra Information**: \(extraInformation.joined(separator: ", "))\n"
        }

        enrichedMessage += "\n## User Message: \(prompt)"

        // Prepare the request body
        let requestBody = CohereChatRequest(
            //model: "bfddfb01-d7c6-4a02-8b25-4d5c3f6136ac-ft", // original tuned model ID
            //model: "bb71f3d8-2ab9-4bf5-a2d9-ac159f81874b-ft", // weight_change_dataset_model ID
            //model: "68db885e-77d2-418a-8777-999e1bec2dc5-ft", // diet_data_model ID
            model: "b325aa57-05f0-4586-8832-94f810210fc4-ft", // combined_model ID
            message: enrichedMessage,
            max_tokens: 800,
            temperature: 0.05
            //seed: 42
        )

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(requestBody)
            print(requestBody)
            

            // Perform the API request
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(String(describing: error))")
                    completion(nil)
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(CohereChatResponse.self, from: data)
                    completion(decodedResponse.text)
                    print(decodedResponse)
                } catch {
                    print("Decoding error: \(error)")
                    completion(nil)
                }
            }.resume()
        } catch {
            print("Error encoding request body: \(error)")
            completion(nil)
        }
    }
}
