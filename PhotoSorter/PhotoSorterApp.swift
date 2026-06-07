//
//  PhotoSorterApp.swift
//  PhotoSorter
//
//  Created by Robert Sanchez on 6/7/26.
//

import SwiftUI
import SwiftData

@main
struct PhotoSorterApp: App {
    let sharedModelContainer: ModelContainer
    @State private var photoLibrary: PhotoLibrary

    init() {
        let schema = Schema([
            Item.self,
            PhotoFeature.self,
            GeocodeCache.self,
            SortPreferences.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.sharedModelContainer = container
            self._photoLibrary = State(initialValue: PhotoLibrary(container: container))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(photoLibrary)
        }
        .modelContainer(sharedModelContainer)
    }
}
