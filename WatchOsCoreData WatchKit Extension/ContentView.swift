//
//  ContentView.swift
//  WatchOsCoreData WatchKit Extension
//
//  Created by SchwiftyUI on 10/12/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var managedObjectContext = (WKExtension.shared().delegate as! ExtensionDelegate).persistentContainer.viewContext
    
    var body: some View {
        FoodList().environment(\.managedObjectContext, managedObjectContext)
    }
}

struct FoodList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Food.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var foodList: FetchedResults<Food>
    
    var body: some View {
        ScrollView {
            ForEach(foodList, id: \.self) { food in
                NavigationLink(destination: EditFood(food: food).environment(\.managedObjectContext, self.managedObjectContext)) {
                    Text("\(food.name)")
                }
            }
            Button(action: {
                let food = Food(context: self.managedObjectContext)
                food.name = "New Food"
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }) {
                Text("Add Food")
            }
            .foregroundColor(Color.green)
        }
    }
}

struct EditFood: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var name: String = ""
    var food: Food
    
    var body: some View {
        VStack {
            TextField("Food Name", text: $name).onAppear {
                self.name = self.food.name
            }
            Button(action: {
                self.food.name = self.name
                self.food.objectWillChange.send()
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            }.foregroundColor(Color.green)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
