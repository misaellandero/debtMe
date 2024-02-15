//
//  FeaturesList.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct FeaturesList: View {
    
    var features = whatsNewFeatures.newFeatures
    
    var body: some View {
        ForEach(features, id: \.id ) { feature in
            if feature.title == "Thanks" {
                Section{
                    FeatureView(feature: feature)
                }
            } else {
                FeatureView(feature: feature)
            }
        }
        .padding()
    }
}

#Preview {
    FeaturesList()
}
