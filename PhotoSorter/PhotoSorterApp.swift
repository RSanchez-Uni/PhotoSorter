//
//  PhotoSorterApp.swift
//  PhotoSorter
//
//  Created by Jegs on 6/7/26.
//

import SwiftUI
import SwiftData

@main
struct PhotoSorterApp: App {
    @State private var photoLibrary = PhotoLibrary()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            PhotoFeature.self,
            GeocodeCache.self,
            SortPreferences.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(photoLibrary)
        }
        .modelContainer(sharedModelContainer)
    }
}
