//
//  DetailImageView.swift
//  debtMe
//
//  Created by Misael Landero on 05/06/24.
//

import SwiftUI

struct DetailImageView: View {
    let photoData : Data?
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    @Environment(\.dismiss) var dismiss
    @State var imageName = ""
    var body: some View {
        ZStack{
            Group{
                if let photoData {
    #if os(macOS)
                    if let image = NSImage(data: photoData){
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
    #elseif os(iOS)
                    if let image = UIImage(data: photoData){
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
    #endif
                }
            }
            .scaleEffect(currentScale * finalScale)
            .offset(x: currentOffset.width + finalOffset.width, y: currentOffset.height + finalOffset.height)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = value
                    }
                    .onEnded { value in
                        finalScale *= currentScale
                        currentScale = 1.0
                    }
                    .simultaneously(with: DragGesture()
                        .onChanged { value in
                            currentOffset = value.translation
                        }
                        .onEnded { value in
                            finalOffset.width += value.translation.width
                            finalOffset.height += value.translation.height
                            currentOffset = .zero
                        }
                    )
            )
            
            VStack{
                if imageName != ""{
                    Text(imageName)
                        .font(.title)
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(10)
                }
                
                Spacer()
                HStack{
                    
                       
                    ShareLink(item:createImage()!,preview: SharePreview(
                     imageName,
                     image: createImage()!
                 )) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
                     #if os(macOS)
                            .buttonStyle(DefaultButtonStyle())
                     #else
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(20)
                     #endif
                     
                    }
                    
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                            .font(Font.system(.headline, design: .rounded).weight(.black))
#if os(macOS)
                    .accentColor(.red)
#else
                    
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(20)
                    #endif
                    }

                }
            }
            .padding()
        }
    }
    
    func createImage() -> Image? {
        if let photoData {
#if os(macOS)
            if let image = NSImage(data: photoData){
                return Image(nsImage: image)
            }
#elseif os(iOS)
            if let image = UIImage(data: photoData){
               return Image(uiImage: image)
            }
#endif
        }
        
        return nil
    }
}


