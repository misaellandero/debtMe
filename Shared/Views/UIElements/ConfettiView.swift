//
//  ConfettiView.swift
//  debtMe
//
//  Created by Misael Landero on 02/10/23.
//

import SwiftUI
#if canImport(ConfettiSwiftUI)
import ConfettiSwiftUI
#endif


struct ConfettiView: View {
    @Binding var counter: Int
    #if os(iOS)
    @State var screenwidht = UIScreen.main.bounds.width * 0.5
    #else
    @State var screenwidht = 200.5//NSScreen.main.width * 0.5
    #endif
  
    var body: some View {
        Group {
            #if canImport(ConfettiSwiftUI)
            ConfettiCannon(counter: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: screenwidht, repetitions: 3, repetitionInterval: 0.7)
                .offset(y: -228)
            #else
            EmptyView()
            #endif
        }
    }
}

#Preview {
    ConfettiView(counter: .constant(0))
}



struct ConfettiMoneyView: View {
    @Binding var counter: Int
    #if os(iOS)
    @State var screenwidht = UIScreen.main.bounds.width * 0.5
    #else
    @State var screenwidht = 200.5//NSScreen.main.width * 0.5
    #endif
     
    
    var body: some View {
        Group {
            #if canImport(ConfettiSwiftUI)
            ConfettiCannon(
                counter: $counter,
                num: 20,
                confettis: [.text("💵"), .text("💶"), .text("💷"), .text("💴")],
                confettiSize: 30,
                openingAngle: Angle(degrees: 0),
                closingAngle: Angle(degrees: 360),
                radius: screenwidht,
                repetitions: 3,
                repetitionInterval: 0.7
            )
            .offset(y: -228)
            #else
            EmptyView()
            #endif
        }
    }
}

