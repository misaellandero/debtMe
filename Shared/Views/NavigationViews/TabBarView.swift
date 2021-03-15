//
//  TabBarView.swift
//  debtMe
//
//  Created by Francisco Misael Landero Ychante on 14/03/21.
//

import SwiftUI

struct TabBarView: View {
    // MARK: - current section selected
    @Binding var sectionSelected : SectionSelected
    
    var body: some View {
        TabBarView(sectionSelected: $sectionSelected){
            
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(sectionSelected: .constant(.contacts))
    }
}
