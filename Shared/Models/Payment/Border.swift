//
//  Border.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI

 
struct TicketViewBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        if colorScheme == .dark {
            ZStack{
                Rectangle()
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                VStack{
                    Border(cutes:40, angle:0)
                    Spacer()
                    Border(cutes:40, angle:180)
                }
            }
            .colorInvert()
        } else {
            ZStack{
                Rectangle()
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                VStack{
                    Border(cutes:40, angle:0)
                    Spacer()
                    Border(cutes:40, angle:180)
                }
            }
        } 
      }
}


struct Border: View {
    
    var cutes = 20
    var angle = 0
    
    var body: some View {
            HStack(spacing: -1) {
                ForEach(0 ..< Int(cutes)) { _ in
                    Image("borderTicket")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 10)
                        .rotationEffect(Angle(degrees: Double(angle)))
                }
            }
  
        
    }
}
 
struct Border_Previews: PreviewProvider {
    static var previews: some View {
        TicketViewBackground()
    }
}
