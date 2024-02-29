//
//  BillsForm.swift
//  debtMe
//
//  Created by Misael Landero on 28/02/24.
//

import SwiftUI

struct BillsForm: View {
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    //Modal presentation
    @Environment(\.presentationMode) var presentationMode
    
    @State var edition : Bool = false
    
    //Data if is edition
    @State var service: Services?
    //Data if is new
    @State var serviceModel = ServicesModel() 
   
    
    var body: some View {
        Group{
            #if os(macOS)
            List{
                Text("\(Image(systemName: "chart.bar.doc.horizontal")) ") +
                Text(edition ? "Edit" : "New")
            }
            
            #else
            NavigationStack{
                List{
                    
                }
                .listStyle(InsetGroupedListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button(action:{
                        closeView()
                    }){
                       Label("Return", image: "xmark")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(action: performSaveAcion){
                       Label(edition ? "Save": "Add", image: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement:.principal){
                    Text("\(Image(systemName: "chart.bar.doc.horizontal")) New")
                }
            }
            #endif
        }
    }
    
    func closeView(){
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func performSaveAcion(){
        if edition {
            //editTransaction()
        } else {
            //saveTransaction()
        }
    }
}

#Preview {
    BillsForm()
}
