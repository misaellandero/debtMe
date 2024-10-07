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
