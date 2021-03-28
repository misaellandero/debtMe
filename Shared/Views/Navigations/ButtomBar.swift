//
//  ButtonBar.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 27/03/21.
//

import SwiftUI
struct ButtomBar : View {
    // MARK: - current section selected
    @Binding var sectionSelected : SectionSelected
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                ButtonFromBar(sectionSelected: $sectionSelected, index: .contacts, label: "Contacts", image: "person.2.fill")
                ButtonFromBar(sectionSelected: $sectionSelected, index: .debts, label: "Debts", image: "dollarsign.square")
                ButtonFromBar(sectionSelected: $sectionSelected, index: .loans, label: "Loans", image: "dollarsign.square.fill")
                ButtonFromBar(sectionSelected: $sectionSelected, index: .settings, label: "Settings", image: "gear")
                ButtonFromBar(sectionSelected: $sectionSelected, index: .budget, label: "Budget", image: "chart.pie.fill")
            }
            .background(BlurdEfectView())
            .cornerRadius(20)
            .padding()
        }.edgesIgnoringSafeArea(.all)
    }
}
 

struct ButtonFromBar: View {
    // MARK: - current section selected
    @Binding var sectionSelected : SectionSelected
    @State var index : SectionSelected
    @State var label : LocalizedStringKey
    @State var image : String
    var indexSelected : Bool {
         index == sectionSelected
    }
    
    var body: some View {
        Button(action:{
            self.sectionSelected = index
        }){
            VStack{
                Image(systemName: image)
                    .font(Font.system(.body, design: .rounded).weight(.black))
                Text(label)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .font(Font.system(.caption2, design: .rounded).weight(.black))
            .padding(10)
            .opacity(indexSelected ? 1 : 0.5)
        }
        .accentColor(indexSelected ? .accentColor  : .gray)
    }
}
