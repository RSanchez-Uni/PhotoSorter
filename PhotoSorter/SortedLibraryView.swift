//
//  SortedLibraryView.swift
//  PhotoSorter
//

import SwiftData
import SwiftUI

struct SortedLibraryView: View {
    @Query private var features: [PhotoFeature]
    @Query private var caches: [GeocodeCache]
    @Query private var preferences: [SortPreferences]

    var body: some View {
        let prefs = preferences.first ?? SortPreferences()
        let cacheByKey = Dictionary(uniqueKeysWithValues: caches.map { ($0.gridKey, $0) })
        let grouper = PhotoGrouper(features: features, cacheByKey: cacheByKey, prefs: prefs)
        let buckets = grouper.build()

        Group {
            if features.isEmpty {
                ContentUnavailableView {
                    Label("Sorting Your Library", systemImage: "hourglass")
                } description: {
                    Text("PhotoSorter is analyzing your photos in the background. Folders will appear shortly.")
                }
            } else if buckets.isEmpty {
                ContentUnavailableView(
                    "No Matching Photos",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("Try turning off the Favorites filter in Sort Settings.")
                )
            } else {
                HierarchyFolderView(buckets: buckets)
            }
        }
    }
}
