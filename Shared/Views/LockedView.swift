//
//  SwiftUIView.swift
//  debtMe
//
//  Created by Misael Landero on 15/02/24.
//

import SwiftUI
import LocalAuthentication

struct LockedView: View {
    
    // MARK: - LocalAuthentication Security Context
    let context = LAContext()
    
    let unlock : () -> Void
    var body: some View {
        VStack{
            ZStack{
                
                Image(systemName: "shield.fill")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .foregroundStyle(Color.accentColor.gradient)
                
                Image(.billetes)
                    .resizable()
                    .scaledToFit()
                
                Image(.pig)
                    .resizable()
                    .scaledToFit()
                
                
                    
            }
            .frame(maxWidth: 300)
            Text("Unlock to see your data")
                .bold()
            
            Button(action: unlock, label: {
                if (context.biometryType == LABiometryType.faceID) {
                    Label("Unlock", systemImage:"faceid")
                } else {
                    Label("Unlock", systemImage:"touchid")
                }
                
            })
            .buttonStyle(BorderedProminentButtonStyle())
            .padding()
        }
    }
}

#Preview {
    LockedView(unlock: {})
}
