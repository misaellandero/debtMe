//
//  EmojiButton.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

/*struct EmojiButton: View {
    
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @State var hovered = false
    @State var emoji : String
    var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            EmojiButtonStyle(hovered: $hovered, emoji: $emoji)
        } else {
            EmojiButtonStyle(hovered: $hovered, emoji: $emoji, fixedFrame: true)
        }
        #elseif os(macOS)
            EmojiButtonStyle(hovered: $hovered, emoji: $emoji, fixedFrame: true)
        #endif
        
        
    }
}*/

struct EmojiButton : View {
    @State private var hovered = false
    @State var emoji : String
    @State var fixedFrame = false
    var body: some View {
        if fixedFrame {
            VStack{
                Text(emoji)
            }
            .frame(width: 30, height: 30)
            .background(hovered ? Color.primary.opacity(0.3) : Color.primary.opacity(0.1))
            .cornerRadius(5)
            .animation(.easeInOut)
            .onHover { isHovered in
                self.hovered = isHovered
            }
            
        } else {
            VStack{
                Text(emoji)
                    .font(.title)
                    .padding()
            }
            .background(hovered ? Color.primary.opacity(0.3) : Color.primary.opacity(0.1))
            .cornerRadius(5)
            .animation(.easeInOut)
            .onHover { isHovered in
                self.hovered = isHovered
            }
        }
       
    }
}

struct EmojiButton_Previews: PreviewProvider {
    static var previews: some View {
        EmojiButton(emoji: "🙃")
    }
}
