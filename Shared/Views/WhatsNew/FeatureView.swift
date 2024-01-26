//
//  FeatureView.swift
//  debtMe (iOS)
//
//  Created by Misael Landero on 24/01/24.
//

import SwiftUI

struct FeatureView: View {
    
    let feature : Feature
    var body: some View {
        HStack{
            Group {
                if feature.system {
                   Image(systemName: feature.image)
                   .resizable()
                   .scaledToFit()
                   .foregroundColor(feature.color)
                    
                } else {
                    Image(feature.image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(feature.color)
                }
            }
            .frame(width:50, height: 50)
            .padding()
             
            VStack(alignment: .leading){
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(feature.des)
                .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            Spacer()
        }
        .padding(.top,5)
    }
}

#Preview {
    FeatureView(feature: Feature())
}
