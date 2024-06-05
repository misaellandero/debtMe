//
//  ImagePickerView.swift
//  debtMe
//
//  Created by Misael Landero on 04/06/24.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var photoData: Data?
    @State var photoSelected: PhotosPickerItem?
    @AppStorage("selectedQuality") private var selectedQuality: JPEGQuality = .lowest
    var body: some View {
        Section{
            
            HStack(){
                Spacer()
                ImageView(photoData: photoData)
                    .frame(height: 250)
                Spacer()
            }
            PhotosPicker(selection: $photoSelected, matching: .images, photoLibrary: .shared()) {
                Label("Select a Photo", systemImage: "photo")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Picker("Quality", selection: $selectedQuality) {
                ForEach(JPEGQuality.allCases){ quality in
                    Text(quality.description).tag(quality)
                }
            }
            
            Text(photoData?.count.formatted(.byteCount(style: .memory)) ?? "0mb")
            
        }
        //change quality selected photo
        .task(id: selectedQuality, {
        
            if let data = try? await
                photoSelected?.loadTransferable(type: Data.self){
                if selectedQuality == .original {
                    photoData =  data
                } else {
                    if let image = UIImage(data: data){
                        photoData = image.jpegData(quality: selectedQuality)
                    }
                }
                
            }
        })
        //Convert to data new picked photo
        .task(id: photoSelected) {
            if let data = try? await
                photoSelected?.loadTransferable(type: Data.self){
                if selectedQuality == .original {
                    photoData =  data
                } else {
                    if let image = UIImage(data: data){
                        photoData = image.jpegData(quality: selectedQuality)
                    }
                }
            }
        }
    }
}

#Preview {
    ImagePickerView(photoData: .constant(nil))
        .frame(width: 200, height: 200)
}
