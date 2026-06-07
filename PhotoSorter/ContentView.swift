//
//  ContentView.swift
//  PhotoSorter
//
//  Created by Jegs on 6/7/26.
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
                .navigationTitle("Photos")
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
            PhotoGridView()
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
    ContentView()
        .environment(PhotoLibrary())
        .modelContainer(for: [Item.self, PhotoFeature.self, GeocodeCache.self, SortPreferences.self], inMemory: true)
}
