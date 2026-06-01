//
//  ImageExtension.swift
//  debtMe
//
//  Created by Misael Landero on 05/06/24.
//

import SwiftUI

enum JPEGQuality: String, CaseIterable, Identifiable {
    case lowest
    case low
    case medium
    case high
    case highest
    case original

    var id: String { self.rawValue }

    var description: LocalizedStringKey {
        switch self {
        case .lowest: return "Lowest"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .highest: return "Highest"
        case .original: return "Original"
        }
    }

    var value: CGFloat {
        switch self {
        case .lowest: return 0.0
        case .low: return 0.25
        case .medium: return 0.5
        case .high: return 0.75
        case .highest: return 1.0
        //Not really used only for the picker 
        case .original: return 1.0
        }
    }
}

#if os(iOS)
extension UIImage {
    func jpegData(quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.value)
    }
}

#elseif os(macOS)
extension NSImage {
    func jpegData(quality: JPEGQuality) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: quality.value])
    }
}


#endif

// MARK: - Typography

enum AppTypography {
    // Brand-ish rounded titles, but keep weights readable.
    static let brandTitle: Font = .system(.title2, design: .rounded).weight(.bold)
    static let brandHeadline: Font = .system(.headline, design: .rounded).weight(.semibold)

    // General purpose
    static let title: Font = .title2.weight(.bold)
    static let headline: Font = .headline.weight(.semibold)
    static let body: Font = .body
    static let caption: Font = .caption
}

extension View {
    func appBrandTitle() -> some View { font(AppTypography.brandTitle) }
    func appBrandHeadline() -> some View { font(AppTypography.brandHeadline) }

    func appTitle() -> some View { font(AppTypography.title) }
    func appHeadline() -> some View { font(AppTypography.headline) }

    /// Use for toolbar/menu label buttons (keeps UI legible and consistent).
    func appToolbarLabel() -> some View { font(AppTypography.brandHeadline) }
}
