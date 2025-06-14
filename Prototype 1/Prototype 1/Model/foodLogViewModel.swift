//
//  foodLogViewModel.swift
//  Prototype 1
//
//  Created by Roberto Martin on 01/01/2025.
//

import Foundation

class foodLogViewModel: ObservableObject {
    @Published var savedFoods: [Product] = []
    
    func saveFoodItem(_ product: Product) {
        savedFoods.append(product)
    }
}
