//
//  ContentView.swift
//  iExpense
//
//  Created by Zakir Ufuk Sahiner on 07.02.24.
//
// 100 Days of SwiftUI project 7

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    // If a struct is Identifiable there must be a something which makes it unique (It can be anything, here we are using UUID)
    // Identifiable declares that this struct is unique see ForEach loop down below to read more about this topic
    var id = UUID() // by assigning id to UUID() we are making sure that it is unique.
    let name: String
    let type: String
    let amount: Double
}

//MARK: Saving Expenses
@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showindAddExpense = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach (expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text(item.type)
                        }
                        
                        Spacer()
                        
                        Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    }
                }
                // instead of it we could also use the ForEach loop which is down below. With id: \.id we are stating that every single item on that ForEach loop is unique by their .id variable which is in our case UUID(). We could also use .name or anything (be sure that that name is also unique.  We don't need to use it because by Identifiable protocol on line 11 we making sure that that struct is unique, so we don't need to say it again extra in our ForEach loop. 
//                ForEach (expenses.items, id: \.id) { item in
//                    Text(item.name)
//                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar{
                Button("Add Expense", systemImage: "plus") {
                    showindAddExpense = true
                }
            }
            .sheet(isPresented: $showindAddExpense){
                AddView(expenses: expenses)
            }
        }
    }
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
