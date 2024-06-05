//
//  ImageView.swift
//  debtMe
//
//  Created by Misael Landero on 04/06/24.
//

import SwiftUI

struct ImageView: View {
    
    let photoData : Data?
    
    var body: some View {
        Group{
            if let photoData {
                #if os(macOS)
                if let image = NSImage(data: photoData){
                     Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                }
                #elseif os(iOS)
                if let image = UIImage(data: photoData){
                     Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                }
                #endif
            }
        } 
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ImageView(photoData: nil)
}
