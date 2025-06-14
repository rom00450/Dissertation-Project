import SwiftUI

struct recipesView: View {
    @State private var categories: [Category] = [] // Holds the fetched categories
    @State private var showFavouritesOnly: Bool = false // State for the toggle
    
    var filteredCategories: [Category] {
        // Filter categories based on the toggle
        showFavouritesOnly ? categories.filter { $0.strCategory.contains("Favourite") } : categories
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                Toggle(isOn: $showFavouritesOnly) {
                    Text("Favourites only")
                }
                ForEach(filteredCategories, id: \.strCategory) { category in
                    NavigationLink(destination: RecipeDetailView(category: category)) {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: category.strCategoryThumb)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView() // Display a loading indicator while the image loads
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            Text(category.strCategory)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                fetchRecipeInfo { fetchedCategories in
                    if let fetchedCategories = fetchedCategories {
                        self.categories = fetchedCategories
                    }
                }
            }
        } detail: {
            Text("Select a recipe")
        }
    }
    
    // Fetch recipe info from API
    func fetchRecipeInfo(completion: @escaping ([Category]?) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/categories.php"
        
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
                let categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(categoryResponse.categories)
                }
            } catch {
                print("JSON decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    struct Category: Decodable {
        let idCategory: String
        let strCategory: String
        let strCategoryThumb: String
        let strCategoryDescription: String
    }
    
    struct CategoryResponse: Decodable {
        let categories: [Category]
    }
}

struct RecipeDetailView: View {
    let category: recipesView.Category
    @State private var recipes: [Recipe] = [] // Recipes within the category
    
    var body: some View {
        List {
            // Static content: Category image and description
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: category.strCategoryThumb)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    
//                    Text(category.strCategory)
//                        .font(.largeTitle)
//                        .bold()
                    
                    Text(category.strCategoryDescription)
                        .font(.body)
                        .padding(.top, 8)
                }
                .padding(.bottom, 16)
            }
            
            // Dynamic content: List of recipes
            Section {
                ForEach(recipes, id: \.idMeal) { recipe in
                    NavigationLink(destination: FocusedRecipeView(recipe: recipe)) {
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
//                            Text()
//                                .font(.headline)
                            //Text that shows the ingredients but need to find a way of displaying all the different objects from the JSON file
                            
                            Text(recipe.strMeal)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.strCategory)
        .onAppear {
            fetchRecipes(for: category.strCategory)
        }
    }
    
    // Fetch recipes for the category
    func fetchRecipes(for category: String) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                return
            }
            
            do {
                let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.recipes = recipeResponse.meals
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }
    
    struct RecipeResponse: Decodable {
        let meals: [Recipe]
    }
    
    struct Recipe: Decodable {
        let idMeal: String
        let strMeal: String
        let strMealThumb: String
    }
}

struct FocusedRecipeView: View {
    let recipe: RecipeDetailView.Recipe
    @State private var recipeDetails: RecipeDetails? = nil
    
    var body: some View {
        ScrollView {
            if let details = recipeDetails {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: details.strMealThumb)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    
                    Text(details.strMeal)
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(details.strInstructions)
                        .font(.body)
                }
                .padding()
            } else {
                ProgressView()
                    .onAppear {
                        fetchRecipeDetails(for: recipe.idMeal)
                    }
            }
        }
        .navigationTitle(recipe.strMeal)
    }
    
    // Fetch detailed recipe info
    func fetchRecipeDetails(for mealID: String) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned from API")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RecipeDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.recipeDetails = response.meals.first
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }
    
    struct RecipeDetailsResponse: Decodable {
        let meals: [RecipeDetails]
    }
    
    struct RecipeDetails: Decodable {
        let strMeal: String
        let strMealThumb: String
        let strInstructions: String
    }
}

#Preview {
    recipesView()
}
