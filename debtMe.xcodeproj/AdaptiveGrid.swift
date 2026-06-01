import SwiftUI

// Universal helpers for grids controlled by a single density slider (0...1)
// 0 => larger cells, fewer columns; 1 => smaller cells, more columns.

public struct AdaptiveGridDensitySlider: View {
    @Binding var density: Double
    public init(density: Binding<Double>) { self._density = density }
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rectangle.grid.2x2").foregroundStyle(.secondary)
            Slider(value: $density, in: 0...1, step: 0.05) { Text("Grid density") }
            Image(systemName: "rectangle.grid.1x2").font(.title3).foregroundStyle(.secondary)
        }
    }
}

public struct AdaptiveGrid<Content: View>: View {
    let density: Double
    let minCell: CGFloat
    let maxCell: CGFloat
    let spacing: CGFloat
    @ViewBuilder let content: (_ cellWidth: CGFloat, _ columns: [GridItem]) -> Content

    public init(density: Double, minCell: CGFloat = 110, maxCell: CGFloat = 220, spacing: CGFloat = 18, @ViewBuilder content: @escaping (_ cellWidth: CGFloat, _ columns: [GridItem]) -> Content) {
        self.density = density
        self.minCell = minCell
        self.maxCell = maxCell
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let cellWidth = Self.cellWidth(for: density, minCell: minCell, maxCell: maxCell)
            let columns = [GridItem(.adaptive(minimum: cellWidth), spacing: spacing)]
            content(cellWidth, columns)
        }
    }

    static func cellWidth(for density: Double, minCell: CGFloat, maxCell: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, density))
        return max(minCell, min(maxCell, maxCell - (maxCell - minCell) * clamped))
    }
}
