//
//  FeaturesList.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct FeaturesList: View {
    
    var features = whatsNewFeatures.appFeatures
    
    var body: some View {
        
        Section(){
            ForEach(features, id: \.id ) { feature in
                if feature.newOnThisVersion {
                        FeatureView(feature: feature)
                }
            }
        }
        
        Section(){
            FeatureView(feature: whatsNewFeatures.thanksSection)
        }
        
        Section(header: Text("All Features")){
            ForEach(features, id: \.id ) { feature in
                if !feature.newOnThisVersion {
                        FeatureView(feature: feature)
                }
            }
        }
        
      
    }
}

#Preview {
    FeaturesList()
}
