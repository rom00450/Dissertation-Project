//
//  FoodLogInView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 06/12/2024.
//

import SwiftUI

class FoodLogViewModel: ObservableObject {
    @Published var savedFoods: [Product] = [] // Array to track saved food items
    
    func saveFoodItem(_ product: Product) {
        savedFoods.append(product)
    }
}

struct FoodLogInView: View {
    @StateObject private var viewModel = FoodLogViewModel() // Shared ViewModel
    @State private var userInput: String = ""
    @State private var searchResults: [Product] = [] // Search results from API

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search for food item", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        findItem()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .keyboardShortcut(.defaultAction)
                    .padding(.trailing)
                }

                // Search Results
                List(searchResults) { product in
                    NavigationLink(
                        destination: ProductDetailView(product: product)
                            .environmentObject(viewModel) // Pass ViewModel to detail view
                    ) {
                        Text(product.name)
                    }
                }
                .padding(.top)
                
                // Navigate to Saved Foods
                NavigationLink(destination: SavedFoodsView().environmentObject(viewModel)) {
                    Text("View Saved Foods")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top)
                }
            }
            .navigationTitle("Search Food")
        }
    }

    func findItem() {
        guard !userInput.isEmpty else {
            print("User input is empty")
            return
        }

        let query = userInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(query)&search_simple=1&action=process&json=1"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let products = json["products"] as? [[String: Any]] {
                    
                    // Parse product data into Product model
                    let results = products.compactMap { productDict -> Product? in
                        guard let name = productDict["product_name"] as? String else { return nil }
                        let brand = productDict["brands"] as? String ?? "Unknown brand"
                        let energy = (productDict["nutriments"] as? [String: Any])?["energy-kcal_100g"] as? Double ?? 0
                        let carbs = (productDict["nutriments"] as? [String: Any])?["carbohydrates_100g"] as? Double ?? 0
                        let fats = (productDict["nutriments"] as? [String: Any])?["fat_100g"] as? Double ?? 0
                        let proteins = (productDict["nutriments"] as? [String: Any])?["proteins_100g"] as? Double ?? 0
                        
                        return Product(id: UUID(), name: name, brand: brand, energy: energy, carbs: carbs, fats: fats, proteins: proteins)
                    }

                    DispatchQueue.main.async {
                        self.searchResults = results
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        task.resume()
    }
}

struct Product: Identifiable {
    let id: UUID
    let name: String
    let brand: String
    let energy: Double
    let carbs: Double
    let fats: Double
    let proteins: Double
}

struct ProductDetailView: View {
    @EnvironmentObject var viewModel: FoodLogViewModel // Shared ViewModel
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Name: \(product.name)")
                .font(.headline)
            Text("Brand: \(product.brand)")
            Text("Energy: \(product.energy) kcal")
            Text("Carbohydrates: \(product.carbs)")
            Text("Fats: \(product.fats)")
            Text("Proteins: \(product.proteins)")

            Spacer()

            Button(action: saveFood) {
                Text("Save food item")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle(product.name)
    }

    func saveFood() {
        viewModel.saveFoodItem(product) // Save product in shared ViewModel
    }
}

struct SavedFoodsView: View {
    @EnvironmentObject var viewModel: FoodLogViewModel // Shared ViewModel

    var body: some View {
        VStack {
            List(viewModel.savedFoods) { product in
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    Text("Energy: \(product.energy) kcal")
                    Text("Carbs: \(product.carbs)")
                    Text("Fats: \(product.fats)")
                    Text("Proteins: \(product.proteins)")
                }
            }
            .navigationTitle("Saved Foods")
        }
    }
}

#Preview {
    FoodLogInView()
}
