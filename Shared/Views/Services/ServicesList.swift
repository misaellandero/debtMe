//
//  ServicesList.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct ServicesList: View {
  
    @State var showNewBill = false
    
    @FetchRequest(entity: ContactLabel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ContactLabel.name, ascending: true)]) var labels: FetchedResults<ContactLabel>
    
    @FetchRequest(entity: Services.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Services.name, ascending: true)]) var services: FetchedResults<Services>
    
    // Computed property to calculate the total amount
    var totalExpenses: Double {
        filteredServices.filter { $0.expense }.reduce(0) { $0 + $1.amount }
    }
    var totalIncome: Double {
        filteredServices.filter { !$0.expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double{
        totalIncome - totalExpenses
    }
    
    @State var selectedTag = "All"
    
    @State var searchQuery = ""
    
    @State var startDate = Date()
    
    @State var endDate =  Date()
    
    
    @State var sortedMode : sortModeServices = .amountDes
    
    var filteredServices : [Services] {
        let sortedServices: [Services]
        
        switch sortedMode {
        case .alfabethAsc :
            sortedServices = services.sorted{
                $0.name ?? "" < $1.name ?? ""
            }
        case .alfabethDes:
            sortedServices = services.sorted{
                $0.name ?? "" > $1.name ?? ""
            }
        case .amountAsc:
            sortedServices = services.sorted{
                $0.wrappedAmount  < $1.wrappedAmount
            }
        case .amountDes:
            sortedServices = services.sorted{
                $0.wrappedAmount > $1.wrappedAmount
            }
        }
        
        let filteredByTag: [Services]
         
         if selectedTag == "All" {
             // No tag selected, use all contacts
             filteredByTag = sortedServices
         } else {
             // Filter contacts based on the selected tag
             filteredByTag = sortedServices.filter { service in
                 service.label?.wrappedName == selectedTag
             }
         }
        
        if searchQuery.isEmpty {
            return filteredByTag
        } else {
            // Further filter contacts based on the search query
            return filteredByTag.filter { contact in
                contact.name?.localizedCaseInsensitiveContains(searchQuery) == true
            }
        }
        
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("summaryServicesSelectd") var summarySelectd: summaryServicesMenu = .balance
    @AppStorage("ShowServicesSummary") var ShowSummary = true
        
    var body: some View {
        List{
            Section(content: {
                DatePicker("Start Date", selection: $startDate)
                     
                DatePicker("End Date", selection: $endDate)
                    
            }, header: {
                Label("Date frame", systemImage: "calendar")
            })
            
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
            
            ForEach(filteredServices) { service in
                NavigationLink(destination: ServiceDetailView(service: service) ) {
                    ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
                }
                .listRowBackground(service.wrappedColor)
            }
            .onDelete(perform: deleteService)
        }
        .toolbar{
            
            #if os(macOS)
            ToolbarItem(placement: .navigation ){
                Text("\(Image(systemName: "chart.bar.doc.horizontal")) Bills")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
            }
            ToolbarItem(placement: .navigation ){
                SearchTextField(searchQuery: $searchQuery)
                
            }
            
            #endif
            
            ToolbarItem(placement: .primaryAction ){
                Button(action:{
                    showNewBill.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill") .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.accentColor)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Label("Sort alphabetically", systemImage: "arrow.up.and.down.text.horizontal")
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Button(action: {
                        sortedMode = .alfabethAsc
                    }) {
                        Label("Ascending A-Z", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        sortedMode = .alfabethDes
                    }) {
                        Label("Descending Z-A", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Sort by Amount", systemImage: "arrow.up.and.down.text.horizontal")
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Button(action: {
                        sortedMode = .amountAsc
                    }) {
                        Label("Lower First", systemImage: "platter.filled.top.and.arrow.up.iphone")
                    }
                    Button(action: {
                        sortedMode = .amountDes
                    }) {
                        Label("Higher First", systemImage: "platter.filled.bottom.and.arrow.down.iphone")
                    }
                    Divider()
                    
                    Label("Tags", systemImage: "tag")
                    
                    .font(Font.system(.headline, design: .rounded).weight(.black))
                    Picker(selection: $selectedTag, label: Text("Filter by tag")) {
                        Text("All").tag("All")
                        ForEach(labels){ label in
                            if !label.labelForService {
                                Text(label.wrappedName).tag(label.wrappedName)
                            }
                            
                        }
                    }
                    
                } label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle.fill")   .font(Font.system(.headline, design: .rounded).weight(.black))
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showNewBill, content: {
            ServicesForm()
        })
        #if os(iOS)
        .navigationTitle("Bills")
        .searchable(text: $searchQuery)
        #endif
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
