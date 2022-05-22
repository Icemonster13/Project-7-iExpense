//
//  ContentView.swift
//  iExpense
//
//  Created by Michael & Diana Pascucci on 5/2/22.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
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
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(expenses.items) { item in
                        if item.type == "Personal" {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.type)
                                }
                                Spacer()
                                Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                                    .modifier(DollarAmountFormatted(amount: item.amount))
                            }
                            .accessibilityElement()
                            .accessibilityLabel("\(item.name), \(item.amount.formatted(.currency(code: Locale.current.currencyCode ?? "USD")))")
                            .accessibilityHint(item.type)
                        }
                    }
                    .onDelete(perform: removeItems)
                } header: {
                    Text("Personal")
                }
                Section {
                    ForEach(expenses.items) { item in
                        if item.type == "Business" {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.type)
                                }
                                Spacer()
                                Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                                    .modifier(DollarAmountFormatted(amount: item.amount))
                            }
                        }
                    }
                    .onDelete(perform: removeItems)
                } header: {
                    Text("Business")
                }
            }
            .navigationTitle("iExpenses")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }
}

struct DollarAmountFormatted: ViewModifier {
    var amount: Double
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 120, height: 30, alignment: .trailing)
            .background(amount < 10 ? Color.blue : amount < 100 ? Color.black : Color.red)
            .foregroundColor(.white)
            .font(.footnote)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
