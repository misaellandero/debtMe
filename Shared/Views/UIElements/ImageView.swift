//
//  ImageView.swift
//  debtMe
//
//  Created by Misael Landero on 04/06/24.
//

import SwiftUI

struct ImageView: View {
    
    let photoData : Data?
    
    var placeHolder = false
    
    var placeHolderImage = Image(.cromaPig)
    
    @State var showFullScreenImage = false
    
    var imagename = ""
    
    var body: some View {
        Group{
            if let photoData {
                #if os(macOS)
                if let image = NSImage(data: photoData){
                     Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .onTapGesture {
                            showFullScreenImage.toggle()
                        }
                }
                else if placeHolder {
                   placeHolderImage
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
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .onTapGesture {
                            showFullScreenImage.toggle()
                        }
                }
                else if placeHolder {
                   placeHolderImage
                       .resizable()
                       .scaledToFit()
                       .cornerRadius(10)
               }
                #endif
            } else if placeHolder {
                placeHolderImage
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showFullScreenImage, content: {
            DetailImageView(photoData: photoData, imageName: imagename)
        })
       
    }
}

#Preview {
    ImageView(photoData: nil)
}
