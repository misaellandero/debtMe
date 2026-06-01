//
//  ImageView.swift
//  debtMe
//
//  Created by Misael Landero on 04/06/24.
//

import SwiftUI

// MARK: - Service icon (square w/ rounded corners)

struct ServiceIconView: View {
    let photoData: Data?
    let placeholder: Image
    let backgroundColor: Color?
    let cornerRadius: CGFloat

    init(
        photoData: Data?,
        placeholder: Image = Image(.cromaPig),
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = 14
    ) {
        self.photoData = photoData
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        ZStack {
            if let backgroundColor {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor.opacity(0.16))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.secondary.opacity(0.08))
            }

            if let photoData, let image = platformImage(from: photoData) {
                GeometryReader { proxy in
                    Image(platformImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: min(proxy.size.width, imageSize(image).width),
                            height: min(proxy.size.height, imageSize(image).height),
                            alignment: .center
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .opacity(0.9)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    #if os(macOS)
    private func platformImage(from data: Data) -> NSImage? { NSImage(data: data) }
    private func imageSize(_ image: NSImage) -> CGSize { image.size }
    #else
    private func platformImage(from data: Data) -> UIImage? { UIImage(data: data) }
    private func imageSize(_ image: UIImage) -> CGSize { image.size }
    #endif
}

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
                    GeometryReader { proxy in
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: min(proxy.size.width, image.size.width),
                                height: min(proxy.size.height, image.size.height),
                                alignment: .center
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .cornerRadius(shadowRadius)
                            .shadow(radius: shadowRadius)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !showModalDetail { return }
                                showFullScreenImage.toggle()
                            }
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
                    GeometryReader { proxy in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: min(proxy.size.width, image.size.width),
                                height: min(proxy.size.height, image.size.height),
                                alignment: .center
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .cornerRadius(shadowRadius)
                            .shadow(radius: shadowRadius)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !showModalDetail { return }
                                showFullScreenImage.toggle()
                            }
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
                placeholderClampedToIntrinsicSize
            }
        }
        .sheet(isPresented: $showFullScreenImage, content: {
            DetailImageView(photoData: photoData, imageName: imagename)
        })
       
    }

    @ViewBuilder
    private var placeholderClampedToIntrinsicSize: some View {
        #if os(macOS)
        let intrinsicSize = NSImage(resource: .cromaPig).size
        GeometryReader { proxy in
            placeHolderImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: min(proxy.size.width, intrinsicSize.width),
                    height: min(proxy.size.height, intrinsicSize.height),
                    alignment: Alignment.center
                )
                .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity, alignment: Alignment.center)
                .cornerRadius(shadowRadius)
        }
        #else
        let intrinsicSize = UIImage(resource: .cromaPig).size
        GeometryReader { proxy in
            placeHolderImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: min(proxy.size.width, intrinsicSize.width),
                    height: min(proxy.size.height, intrinsicSize.height),
                    alignment: Alignment.center
                )
                .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity, alignment: Alignment.center)
                .cornerRadius(shadowRadius)
        }
        #endif
    }
}

#Preview {
    ImageView(photoData: nil)
}

private extension Image {
    #if os(macOS)
    init(platformImage: NSImage) { self.init(nsImage: platformImage) }
    #else
    init(platformImage: UIImage) { self.init(uiImage: platformImage) }
    #endif
}
