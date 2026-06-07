//
//  BucketPhotoGrid.swift
//  PhotoSorter
//

import Photos
import SwiftUI

struct BucketPhotoGrid: View {
    let photoIdentifiers: [String]

    @State private var assets: [PHAsset] = []

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]

    var body: some View {
        ScrollView {
            if assets.isEmpty {
                ContentUnavailableView(
                    "No Photos",
                    systemImage: "photo.on.rectangle",
                    description: Text("This folder is empty.")
                )
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        NavigationLink {
                            PhotoDetailView(asset: asset)
                        } label: {
                            PhotoThumbnail(asset: asset)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
            }
        }
        .task(id: photoIdentifiers) {
            assets = Self.fetchAssets(identifiers: photoIdentifiers)
        }
    }

    private static func fetchAssets(identifiers: [String]) -> [PHAsset] {
        guard !identifiers.isEmpty else { return [] }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        return (0..<result.count).map { result.object(at: $0) }
    }
}
