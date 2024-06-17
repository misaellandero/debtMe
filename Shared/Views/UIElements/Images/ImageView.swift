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
    var showModalDetail = true
    var shadowRadius : CGFloat = 10
    var body: some View {
        Group{
            if let photoData {
                #if os(macOS)
                if let image = NSImage(data: photoData){
                     Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(shadowRadius)
                        .shadow(radius: shadowRadius)
                        .onTapGesture {
                            if !showModalDetail {return}
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
                        .cornerRadius(shadowRadius)
                        .shadow(radius: shadowRadius)
                        .onTapGesture {
                            if !showModalDetail {return}
                            showFullScreenImage.toggle()
                        }
                }
                else if placeHolder {
                   placeHolderImage
                       .resizable()
                       .scaledToFit()
                       .cornerRadius(shadowRadius)
               }
                #endif
            } else if placeHolder {
                placeHolderImage
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(shadowRadius)
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
