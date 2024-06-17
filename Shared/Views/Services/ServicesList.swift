//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesList: View {
  
    @State var showNewBill = false
    
    @FetchRequest(entity: Services.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]) var services: FetchedResults<Services>
    
    // Computed property to calculate the total amount
    var totalExpenses: Double {
        services.filter { $0.expense }.reduce(0) { $0 + $1.amount }
    }
    var totalIncome: Double {
        services.filter { !$0.expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double{
        totalIncome - totalExpenses
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("summaryServicesSelectd") var summarySelectd: summaryServicesMenu = .balance
    @AppStorage("ShowServicesSummary") var ShowSummary = true
        
    var body: some View {
        List{
            if ShowSummary {
                Section(){
                    Group{
                        switch summarySelectd {
                        case .balance:
                            VStack(alignment: .leading){
                                Text("Balance")
                                    .font(.caption)
                                Text(balance.toCurrencyString())
                                    .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                                
                            }
                        case .expense:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Expenses"))
                                    .font(.caption)
                                Text("-" + totalExpenses.toCurrencyString())
                                    .foregroundColor(.red)
                                
                            }
                        case .income:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Income"))
                                    .font(.caption)
                                    
                                Text(totalIncome.toCurrencyString())
                                    .foregroundColor(.blue)
                                
                            }
                        case .all:
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Income"))
                                    .font(.caption)
                                    
                                Text(totalIncome.toCurrencyString())
                                    .foregroundColor(.blue)
                                
                            }
                            VStack(alignment: .leading){
                                Text(LocalizedStringKey("Expenses"))
                                    .font(.caption)
                                Text("-" + totalExpenses.toCurrencyString())
                                    .foregroundColor(.red)
                                
                            }
                            VStack(alignment: .leading){
                                Text("Balance")
                                    .font(.caption)
                                Text(balance.toCurrencyString())
                                    .foregroundStyle(balance >= 0 ? Color.primary : Color.red)
                                
                            }
                        }
                    }
                    .bold()
                    .font(.largeTitle)
                    
                    Picker("Summary", selection: $summarySelectd) {
                        ForEach(summaryServicesMenu.allCases, id:\.self ){ option in
                            Text(LocalizedStringKey(option.rawValue))
                                .tag(option)
                        }
                    }
                    #if os(visionOS)
                    .pickerStyle(MenuPickerStyle())
                    #else
                    .pickerStyle(SegmentedPickerStyle())
                    #endif
                }
            }
            
            ForEach(services) { service in
                NavigationLink(destination: ServiceDetailView(service: service) ) {
                    ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image)
                }
            }
            .onDelete(perform: deleteService)
        }
        .navigationTitle("Bills") 
        .toolbar{
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showNewBill.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill") .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showNewBill, content: {
            ServicesForm()
        })
    }
    private func deleteService(at offsets: IndexSet) {
           for index in offsets {
               let service = services[index]
               viewContext.delete(service)
           }
           do {
               try viewContext.save()
           } catch {
               // Handle the error appropriately in a real app
               print("Error saving context after delete: \(error.localizedDescription)")
           }
       }
}

#Preview {
    NavigationStack{
        ServicesList()
    }
}
