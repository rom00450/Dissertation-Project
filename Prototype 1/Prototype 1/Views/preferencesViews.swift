//
//  preferencesViews.swift
//  Prototype 1
//
//  Created by Roberto Martin on 21/12/2024.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct preferencesViews: View {
    let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    @State private var selectedGender = "Male"
    @State private var selectedAge: Double = 18
    @State private var selectedWeight: Int = 70
    @State private var selectedHeight: Int = 170
    @State private var goalBodyWeight: Int = 75
    @State private var selectedDietaryRequirements = "None"
    @State private var selectedGoal = "None"
    @State private var dietaryInput: String = ""
    @State private var userInput: String = ""
    @State private var userAllergies: String = ""
    @State private var dislikedFoods: [String] = []
    @State private var userAllergiesList: [String] = []
    @State private var extraInformation: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var userExtraInformation: String = ""
    @State private var selectedActivityLevel = "Sedentary"

    let weightRange = 1...400
    let heightRange = 100...250
    let weightGoalRange = 1...400
    let dietaryRequirements = ["None", "Vegetarian", "Vegan", "Gluten-free", "Dairy-free", "Egg-free", "Nut-free", "Shellfish-free", "Seafood-free", "Other"]
    let goal = ["None", "Gain weight", "Lose weight", "Gain muscle"]
    let genders = ["Male", "Female"]
    let activityLevel = ["Sedentary", "Lightly active", "Moderately active", "Highly active"]
    
    private var BMI: Double? {
        guard selectedHeight > 0 else { return nil }
        let heightInMeters = Double(selectedHeight) / 100
        return Double(selectedWeight) / (heightInMeters * heightInMeters)
    }

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading preferences...")
            } else {
                Form {
                    Section {
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(genders, id: \.self) {
                                Text($0)
                            }
                        }
                        HStack {
                            Text("Age: \(Int(selectedAge))")
                            Slider(value: $selectedAge, in: 18...100, step: 1)
                        }
                        Picker("Weight (Kg)", selection: $selectedWeight) {
                            ForEach(weightRange, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        Picker("Weight Goal (Kg)", selection: $goalBodyWeight) {
                            ForEach(weightGoalRange, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        Picker("Height (cm)", selection: $selectedHeight) {
                            ForEach(heightRange, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        Picker("Goal", selection: $selectedGoal) {
                            ForEach(goal, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Activity Level", selection: $selectedActivityLevel) {
                            ForEach(activityLevel, id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Dietary Requirements", selection: $selectedDietaryRequirements) {
                            ForEach(dietaryRequirements, id: \.self) {
                                Text($0)
                            }
                        }
                        if selectedDietaryRequirements == "Other" {
                            TextField("Enter your preference", text: $dietaryInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Save Preference") {
                                if !dietaryInput.isEmpty {
                                    selectedDietaryRequirements = dietaryInput
                                    dietaryInput = ""
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        TextField("Add any allergies", text: $userAllergies)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add to list") {
                            addToList(userAllergies, list: &userAllergiesList)
                            userAllergies = ""
                        }
                        .buttonStyle(.borderedProminent)
                        TextField("Add disliked food", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add to list") {
                            addToList(userInput, list: &dislikedFoods)
                            userInput = ""
                        }
                        .buttonStyle(.borderedProminent)
                        TextField("Extra information", text: $userExtraInformation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add to list") {
                            addToList(userExtraInformation, list: &extraInformation)
                            userExtraInformation = ""
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if !userAllergiesList.isEmpty {
                        Section(header: Text("Allergies")) {
                            List {
                                ForEach(userAllergiesList, id: \.self) { allergy in
                                    Text(allergy)
                                }
                                .onDelete(perform: deleteAllergies)
                            }
                        }
                    }

                    if !dislikedFoods.isEmpty {
                        Section(header: Text("Disliked Foods")) {
                            List {
                                ForEach(dislikedFoods, id: \.self) { food in
                                    Text(food)
                                }
                                .onDelete(perform: deleteFood)
                            }
                        }
                    }

                    if !extraInformation.isEmpty {
                        Section(header: Text("Extra Information")) {
                            List {
                                ForEach(extraInformation, id: \.self) { info in
                                    Text(info)
                                }
                                .onDelete(perform: deleteExtraInformation)
                            }
                        }
                    }
                }
                .navigationTitle("Preferences")
                .toolbar {
                    Button("Submit") {
                        savePreferences()
                    }
                }
            }
        }
        .onAppear{
            if isLoading{
                fetchPreferences()
            }
        }
    }

    private func fetchPreferences() {
        guard let currentUser = Auth.auth().currentUser else {
            DispatchQueue.main.async{
                self.errorMessage = "User not logged in."
                self.isLoading = false
            }
            return
        }
        
        db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
            DispatchQueue.main.async{
                if let error = error {
                    self.errorMessage = "Failed to load preferences: \(error.localizedDescription)"
                } else if let data = snapshot?.data() {
                    self.selectedGender = data["gender"] as? String ?? "Male"
                    self.selectedAge = data["age"] as? Double ?? 18
                    self.selectedWeight = data["weight (kg)"] as? Int ?? 70
                    self.goalBodyWeight = data["goalWeight(kg)"] as? Int ?? 75
                    self.selectedHeight = data["height (cm)"] as? Int ?? 170
                    self.selectedDietaryRequirements = data["dietaryPreference"] as? String ?? "None"
                    self.selectedGoal = data["fitnessGoal"] as? String ?? "None"
                    self.selectedActivityLevel = data["activityLevel"] as? String ?? "Sedentary"
                    self.userAllergiesList = data["allergies"] as? [String] ?? []
                    self.dislikedFoods = data["dislikedFoods"] as? [String] ?? []
                    self.extraInformation = data["extraInformation"] as? [String] ?? []
                } else {
                    self.errorMessage = "No preferences found for this user."
                }
                self.isLoading = false
            }
        }
    }


    private func savePreferences() {
        guard let userId = userId else {
            print("Error: User not logged in.")
            return
        }

        let preferencesData: [String: Any] = [
            "gender": selectedGender,
            "age": selectedAge,
            "weight (kg)": selectedWeight,
            "goalWeight(kg)": goalBodyWeight,
            "height (cm)": selectedHeight,
            "BMI": BMI ?? 0.0,
            "dietaryPreference": selectedDietaryRequirements,
            "fitnessGoal": selectedGoal,
            "activityLevel": selectedActivityLevel,
            "allergies": userAllergiesList,
            "dislikedFoods": dislikedFoods,
            "extraInformation": extraInformation
        ]

        db.collection("users").document(userId).setData(preferencesData, merge: true) { error in
            if let error = error {
                print("Error saving preferences: \(error.localizedDescription)")
            } else {
                print("Preferences saved successfully!")
            }
        }
    }

    private func addToList(_ text: String, list: inout [String]) {
        if !text.isEmpty {
            list.append(text)
        }
    }

    private func deleteFood(at offsets: IndexSet) {
        dislikedFoods.remove(atOffsets: offsets)
    }

    private func deleteAllergies(at offsets: IndexSet) {
        userAllergiesList.remove(atOffsets: offsets)
    }

    private func deleteExtraInformation(at offsets: IndexSet) {
        extraInformation.remove(atOffsets: offsets)
    }
}

#Preview {
    preferencesViews()
}
