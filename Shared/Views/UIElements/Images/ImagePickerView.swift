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
    
   @State var includeImage = false
    var imagename = ""
    var body: some View {
        Toggle("Include Image", isOn: $includeImage)
        if includeImage {
            Section{
                
                HStack(){
                    Spacer()
                    ImageView(photoData: photoData, placeHolder: true, imagename: imagename)
                        .frame(height: 250)
                    Spacer()
                }
            }
            Section{
                #if os(macOS)
                HStack{
                    PhotosPicker(selection: $photoSelected, matching: .images, photoLibrary: .shared()) {
                        Label("Select a Photo", systemImage: "photo")
                    }
                    
             
                    Button("Delete", systemImage: "trash") {
                        photoData =  Data()
                        photoSelected = nil
                    }
                    .accentColor(.red)
                }
                #else
                
                PhotosPicker(selection: $photoSelected, matching: .images, photoLibrary: .shared()) {
                    Label("Select a Photo", systemImage: "photo")
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.accentColor)
                .padding()
         
                Button("Delete", systemImage: "trash") {
                    photoData =  Data()
                    photoSelected = nil
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.red)
                .padding()
                #endif
            }
            Section{
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
                        savePhotoData(data: data)
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
                        savePhotoData(data: data)
                    }
                }
            }
        }
        
    }
    
    func savePhotoData(data: Data){
        #if os(macOS)
        if let image = NSImage(data: data){
            photoData = image.jpegData(quality: selectedQuality)
        }
        #else
        if let image = UIImage(data: data){
            photoData = image.jpegData(quality: selectedQuality)
        }
        #endif
        
    }
}

#Preview {
    ImagePickerView(photoData: .constant(nil))
        .frame(width: 200, height: 200)
}
