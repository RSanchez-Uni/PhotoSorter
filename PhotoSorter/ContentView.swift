//
//  ContentView.swift
//  PhotoSorter
//
//  Created by Robert Sanchez on 6/7/26.
//

import SwiftUI
import SwiftData
import Photos

struct ContentView: View {
    @Environment(PhotoLibrary.self) private var library
    @State private var showingSortSettings = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("PhotoSorter")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSortSettings = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                .sheet(isPresented: $showingSortSettings) {
                    HierarchyPickerView()
                }
        }
        .task {
            await library.requestAccess()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch library.status {
        case .authorized, .limited:
            SortedLibraryView()
        case .denied, .restricted:
            ContentUnavailableView(
                "Photo Access Denied",
                systemImage: "photo.on.rectangle.angled",
                description: Text("Enable photo access in Settings to sort your library.")
            )
        case .notDetermined:
            ProgressView("Requesting access…")
        @unknown default:
            EmptyView()
        }
    }
}

#Preview {
    let schema = Schema([Item.self, PhotoFeature.self, GeocodeCache.self, SortPreferences.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    return ContentView()
        .environment(PhotoLibrary(container: container))
        .modelContainer(container)
}
