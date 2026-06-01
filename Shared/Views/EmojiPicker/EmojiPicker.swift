//
//  EmojiPicker.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct EmojiPicker: View {
    
    @Binding var emoji : String
    @State private var gridDensity: Double = 0.5
    
    
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
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Choose an Emoji")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            Divider()

            EmojiGridDensityControl(density: animatedGridDensity)
                .padding(.horizontal, 8)

            GeometryReader { proxy in
                ScrollView {
                    EmojiGrid(
                        emojis: emojis,
                        density: gridDensity,
                        availableWidth: proxy.size.width - 12,
                        minSize: 28,
                        maxSize: 72,
                        spacing: 8
                    ) { selectedEmoji in
                        emoji = selectedEmoji
                    }
                }
            }
        }
        .frame(width: 200, height: 230)
        .padding()
    }

    private var animatedGridDensity: Binding<Double> {
        Binding(
            get: { gridDensity },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.22)) {
                    gridDensity = newValue
                }
            }
        )
    }
}

struct EmojiSelecter: View {
    
    @Binding var emoji : String
    @State private var gridDensity: Double = 0.5
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                EmojiGridDensityControl(density: animatedGridDensity)
                    .padding(.horizontal, 12)

                GeometryReader { proxy in
                    ScrollView {
                        EmojiGrid(
                            emojis: emojis,
                            density: gridDensity,
                            availableWidth: proxy.size.width - 24,
                            minSize: 36,
                            maxSize: 64,
                            spacing: 10
                        ) { selectedEmoji in
                            emoji = selectedEmoji
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Choose an Emoji")
        }
    }

    private var animatedGridDensity: Binding<Double> {
        Binding(
            get: { gridDensity },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.22)) {
                    gridDensity = newValue
                }
            }
        )
    }
}

private struct EmojiGridDensityControl: View {
    @Binding var density: Double

    var body: some View {
        VStack(spacing: 6) {
            Text("Grid Density")
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(.secondary)
                Slider(value: $density, in: 0...1, step: 0.05) {
                    Text("Grid Density")
                }
                Image(systemName: "square.grid.3x3")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct EmojiGrid: View {
    let emojis: [String]
    let density: Double
    let availableWidth: CGFloat
    let minSize: CGFloat
    let maxSize: CGFloat
    let spacing: CGFloat
    let selectEmoji: (String) -> Void

    private var metrics: (itemWidth: CGFloat, columns: [GridItem], rows: Int, height: CGFloat) {
        let width = max(minSize, availableWidth)
        let clampedDensity = max(0, min(1, density))
        let desired = max(minSize, min(maxSize, maxSize - (maxSize - minSize) * clampedDensity))
        let columnsCount = max(1, Int(floor((width + spacing) / (desired + spacing))))
        let itemWidth = (width - spacing * CGFloat(columnsCount - 1)) / CGFloat(columnsCount)
        let rows = Int(ceil(Double(emojis.count) / Double(columnsCount)))
        let height = CGFloat(rows) * itemWidth + CGFloat(max(0, rows - 1)) * spacing + 8
        let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columnsCount)
        return (itemWidth, columns, rows, height)
    }

    var body: some View {
        let metrics = metrics

        LazyVGrid(columns: metrics.columns, alignment: .leading, spacing: spacing) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    selectEmoji(emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: max(22, metrics.itemWidth * 0.7)))
                        .minimumScaleFactor(0.6)
                        .frame(width: metrics.itemWidth, height: metrics.itemWidth)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(height: metrics.height, alignment: .top)
        .animation(.easeInOut(duration: 0.22), value: density)
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker(emoji: .constant("🙂"))
    }
}
