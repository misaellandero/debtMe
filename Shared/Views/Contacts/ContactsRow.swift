//
//  ContactsRow.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct ContactsRow: View {
    @ObservedObject var contact : Contact
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    var showDetails = false
    
    var body: some View {
        
        ZStack(alignment: .leading){
            VStack{
                HStack{
                    VStack{
                        ContactAvatarView(
                            imageData: contact.avatarImage,
                            emoji: contact.wrappedEmoji,
                            size: 62,
                            cornerRadius: 20
                        )
                    }
                    
                    VStack(alignment: .leading){
                        
                        HStack{
    #if os(visionOS)
                            Text(contact.wrappedName)
    #else
                            Text(contact.wrappedName)
                                .font(Font.system(.title, design: .rounded).weight(.bold))
    #endif
                            
                        }
                        
                        if showDetails {
                            HStack{
                                Text(LocalizedStringKey("They Owe me"))
                                Spacer()
                                Text(contact.totalLoans.toCurrencyString())
                                    .foregroundColor(.blue)
                                
                            }
                            HStack{
                                Text(LocalizedStringKey("I Owe Them"))
                                Spacer()
                                Text(contact.totalDebt.toCurrencyString())
                                    .foregroundColor(.orange)
                                
                            }
                        }
                        
    #if os(visionOS)
                        VStack(alignment: .leading){
                            Text("Balance")
                            
                            Text(contact.balance.toCurrencyString())
                            
                        }
    #else
                        HStack{
                            Text("Balance")
                            
                            Spacer()
                            Text(contact.balance.toCurrencyString())
                            
                        }
    #endif
                        
                        
                        
                    }
                    Spacer()
                }
                .font(Font.system(.body, design: .rounded).weight(.semibold))
                .padding(3)
                .listRowBackground(Color.secondary.opacity(0.2))
                HStack{
                    Spacer()
                    if contact.haveALabel {
                        Text(contact.WrappedLabelName)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(4)
                            .font(Font.system(.caption, design: .rounded).weight(.semibold))
                            .background(contact.WrappedLabelColor)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
          
            
#if os(visionOS)
            if contact.haveALabel {
                HStack{
                    Image(systemName: "circle.fill")
                        .foregroundColor(contact.WrappedLabelColor)
                    Text(contact.WrappedLabelName)
                        .fontWeight(.bold)
                        .padding(4)
                        .cornerRadius(10)
                }
            }
#endif
        }
        
    }
}

struct ContactAvatarView: View {
    let imageData: Data?
    let emoji: String
    var size: CGFloat = 56
    var cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(0.2))

            if let imageData, let image = contactAvatarPlatformImage(from: imageData) {
                contactAvatarImage(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.52))
                    .minimumScaleFactor(0.65)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func contactAvatarImage(_ image: ContactAvatarPlatformImage) -> Image {
        #if os(macOS)
        Image(nsImage: image)
        #else
        Image(uiImage: image)
        #endif
    }
}

private func contactAvatarPlatformImage(from data: Data) -> ContactAvatarPlatformImage? {
    #if os(macOS)
    NSImage(data: data)
    #else
    UIImage(data: data)
    #endif
}

#if os(macOS)
private typealias ContactAvatarPlatformImage = NSImage
#else
private typealias ContactAvatarPlatformImage = UIImage
#endif
