//
//  scannerView.swift
//  Prototype 1
//
//  Created by Roberto Martin on 12/11/2024.
//

import SwiftUI
import StoreKit

struct NutritionalInfo: Identifiable {
    let id = UUID()
    let calories: String
    let protein: String
    let carbohydrates: String
}

struct scannerView: View {
    let data: [NutritionalInfo] = [
        NutritionalInfo(calories: "200", protein: "15g", carbohydrates: "30g"),
        NutritionalInfo(calories: "150", protein: "10g", carbohydrates: "25g"),
        NutritionalInfo(calories: "300", protein: "20g", carbohydrates: "50g"),
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    struct ProductResponse: Codable {
        let product: Product?
    }

    struct Product: Codable {
        let product_name: String?
        let ingredients_text: String?
        let image_url: String?
        let nutriments: Nutriments?
    }
    
    struct Nutriments: Codable{
        let energyKcal100g: Double?
        enum CodingKeys: String, CodingKey {
                case energyKcal100g = "energy-kcal_100g"
            }
    }
    
    @State private var scannedCode: String?
    @State private var isPresentingScanner = false
    @State private var productName: String?
    @State private var productIngredients: String?
    @State private var energyKcal100g: String?
    @State private var isPresentingLogScreen = false

    

    var body: some View {
        
        VStack {
            Text("Overview")

            
            
            if let productName = productName {
                Text("Product Name: \(productName)")
                    .font(.headline)
            }
            
//            if let productIngredients = productIngredients {
//                Text("Ingredients: \(productIngredients)")
//                    .font(.subheadline)
//            }
            
            if let energyKcal = energyKcal100g {
                    Text("Energy: \(energyKcal)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            
            HStack{
                // Barcode Scanner Button
                Button("Scan Barcode") {
                    isPresentingScanner = true
                }
                .sheet(isPresented: $isPresentingScanner) {
                    BarcodeScannerView { code in
                        scannedCode = code
                        isPresentingScanner = false
                        handleScannedBarcode(code) // Fetch product info after scanning
                    }
                }
                Button("Log in food"){
                    isPresentingLogScreen = true
                }
                .sheet(isPresented: $isPresentingLogScreen){
                    FoodLogInView()
                }
                
            }
            
            
            // Grid Display
            HStack {
                Text("Calories")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                Text("Protein")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                Text("Carbohydrates")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(data) { item in
                    VStack {
                        Text(item.calories)
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        Text(item.protein)
                            .font(.title2)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        Text(item.carbohydrates)
                            .font(.title2)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }

    }
    
    // Fetch product info from API
    func fetchProductInfo(for barcode: String, completion: @escaping (Product?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                completion(nil)
                return
            }
            
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(productResponse.product)
                }
            } catch {
                print("JSON decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // Handle the scanned barcode and fetch the product info
    func handleScannedBarcode(_ barcode: String) {
        fetchProductInfo(for: barcode) { product in
            if let product = product {
                self.productName = product.product_name ?? "Unknown"
                self.productIngredients = product.ingredients_text ?? "No ingredients listed"
                
                if let energy = product.nutriments?.energyKcal100g {
                                self.energyKcal100g = "\(energy) kcal per 100g"
                            } else {
                                self.energyKcal100g = "Energy data not available"
                            }
            } else {
                print("Product not found for barcode: \(barcode)")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        scannerView()
    }
}


