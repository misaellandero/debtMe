//
//  EmojiPicker.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct EmojiPicker: View {
    
    @Binding var emoji : String
    
    
    // MARK: - Screen Size for determining ipad or iphone screen
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    var emojis : [String] {
        var emojis = [String]()
        for range in Emojis.emojiRanges {
            for i in Emojis.modifiers {
                let c = String(range + i)
                emojis.append(c)
            }
        }
        
        for emoji in Emojis.extraEmojis {
            emojis.append(emoji)
        }
        
        return emojis
    }
    
    let columns = [
        GridItem(spacing: 0),
        GridItem(spacing: 0),
        GridItem(spacing: 0),
        GridItem(spacing: 0),
        GridItem(spacing: 0),
    ]
    
    var body: some View {
        
        VStack{
            ScrollView {
                Text("Chose An Emoji")
                    .font(.headline)
                Divider()
                LazyVGrid(columns: columns, alignment: .leading, spacing: 3) {
                    ForEach(emojis, id: \.self) { emoji in
                        EmojiButton(emoji: emoji, fixedFrame: true)
                            .frame(width: 30, height: 30)
                            .onTapGesture{
                                self.emoji = emoji
                            }
                        
                    }
                }
                //.padding()
            }
        }
        .frame(width: 165, height: 200)
        .padding()
        
    }
}

struct EmojiSelecter: View {
    
    @Binding var emoji : String
    
    var emojis : [String] {
        var emojis = [String]()
        for range in Emojis.emojiRanges {
            for i in Emojis.modifiers {
                let c = String(range + i)
                emojis.append(c)
            }
        }
        
        for emoji in Emojis.extraEmojis {
            emojis.append(emoji)
        }
        
        return emojis
    }
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
     
    
    var body: some View {
        NavigationView{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        EmojiButton(emoji: emoji)
                            .onTapGesture{
                                self.emoji = emoji
                            }
                    }
                }
                .padding(.horizontal)
            }
            //.frame(maxHeight: 300)
            .navigationTitle("Chose An Emoji")
        }
        
    }
}

 

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker(emoji: .constant("🙂"))
    }
}
