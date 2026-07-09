//
//  FeaturesList.swift
//  debtMe
//
//  Created by Misael Landero on 26/01/24.
//

import SwiftUI

struct FeaturesList: View {

    /// When true (Settings), shows the full feature history grouped by version.
    /// When false (welcome sheet), shows only the current release.
    var showAllVersions = false

    var body: some View {

        if showAllVersions {
            ForEach(whatsNewFeatures.versions) { group in
                Section(header: Text("Version \(group.version)")) {
                    ForEach(group.features, id: \.id) { feature in
                        FeatureView(feature: feature)
                    }
                }
            }
        } else {
            Section() {
                ForEach(whatsNewFeatures.latest.features, id: \.id) { feature in
                    FeatureView(feature: feature)
                }
            }
        }

        Section() {
            FeatureView(feature: whatsNewFeatures.thanksSection)
        }
    }
}

#Preview {
    List {
        FeaturesList(showAllVersions: true)
    }
}
