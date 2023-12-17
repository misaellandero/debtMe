//
//  TotalsView.swift
//  debtMe
//
//  Created by Misael Landero on 18/04/23.
//

import SwiftUI

struct TotalsView: View {
    
    var amount : Double
    @Binding var current : Double
    var left : Double {
        amount - current
    }
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                VStack(alignment: .trailing){
                    Text("Total ")
                        .bold()
                    Text("Cover ")
                        .bold()
                    Text("Left ")
                        .bold()
                }
                
                VStack(alignment: .leading){
                    Text("\(amount.toCurrencyString())")
                    Text("\(current.toCurrencyString())")
                    Text("\(left.toCurrencyString())")
                }
                .multilineTextAlignment(.trailing)
                 
                
               DebtCoverView(total:amount, current:current)
                        .frame(height:50)
                        .animation(.easeOut(duration: 1.5))
            }
            .padding()
            .background(Material.ultraThinMaterial)
            .cornerRadius(10)
        }
        .padding()
    }
}
 
 
struct DebtCoverView: View {
    let total: Double
    let current: Double
    
    var percentage : Double {
       return current / total
    }
    
    var body: some View {
        
        return ZStack {
            Circle()
                .stroke(Color.red, lineWidth: 10)
                .opacity(0.3)
            Circle()
                .trim(from: 0.0, to: CGFloat(percentage))
                .stroke(Color.green, lineWidth: 10)
                .rotationEffect(.degrees(-90))
                
            Group{
                Text(String(format: "%.0f%%", percentage * 100))
                    .animation(.default) 
            }
            .font(Font.caption.weight(.bold))
            .padding()
        }
    }
}

struct TotalsViewRow: View {
    
    var amount : Double
    @Binding var current : Double
    var left : Double {
        amount - current
    }
    
    var body: some View {
        HStack{
            Text("Cover ")
            Spacer()
            Text("\(current.toCurrencyString())")
        }
        HStack{
            Text("Left ")
            Spacer()
            Text("\(left.toCurrencyString())")
        }
    }
}
