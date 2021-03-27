//
//  BlurdEfectView.swift
//  debtMe (iOS)
//
//  Created by Francisco Misael Landero Ychante on 27/03/21.
//

import SwiftUI

struct BlurdEfectView : View {
    // MARK: - Configuraciones del Usuario
    @EnvironmentObject var settings : UserPreferences
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body : some View {
        ZStack{
            settings.getThemeColor().opacity(0.2)
            if colorScheme == .light {
                VisualEffectView(effect: UIBlurEffect(style: .light))
                
            } else {
                VisualEffectView(effect: UIBlurEffect(style: .dark))}
        }
    }
}

struct BlurdEfectView_Previews: PreviewProvider {
    static var previews: some View {
        BlurdEfectView()
    }
}
