//
//  SearchTextField.swift
//  debtMe
//
//  Created by Misael Landero on 16/12/23.
//

import SwiftUI
 
//SearchBar SwiftUI component
struct SearchTextField: View {
    @Binding var searchQuery: String

    var body: some View {
        ZStack {
            
            TextField("􀊫 Search", text: $searchQuery)
                .onReceive(searchQuery.publisher.collect()) {
                      self.searchQuery = String($0.prefix(22))
                  }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .frame(width: 200)
                
            
            if !searchQuery.isEmpty {
                HStack{
                    Spacer()
                    Button(action:
                            {
                        searchQuery = ""
                    })
                    {
                        Image(systemName: "delete.left")
                    }
                    .padding(.trailing, 4)
                }
                .frame(width: 200)
            }
              
        } .padding(.horizontal)
    }
}

#Preview {
    SearchTextField(searchQuery: .constant("Test"))
}
