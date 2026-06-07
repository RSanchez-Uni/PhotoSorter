//
//  PhotoGridView.swift
//  PhotoSorter
//

import Photos
import SwiftUI

struct PhotoGridView: View {
    @Environment(PhotoLibrary.self) private var library

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]

    var body: some View {
        ScrollView {
            if let assets = library.assets, assets.count > 0 {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<assets.count, id: \.self) { index in
                        PhotoThumbnail(asset: assets.object(at: index))
                    }
                }
                .padding(2)
            } else {
                ContentUnavailableView(
                    "No Photos",
                    systemImage: "photo.on.rectangle",
                    description: Text("Your library appears to be empty.")
                )
                .padding(.top, 80)
            }
        }
    }
}

struct PhotoThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Color.gray.opacity(0.15)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipped()
            .contentShape(Rectangle())
            .task(id: asset.localIdentifier) {
                image = await Self.loadThumbnail(for: asset)
            }
    }

    private static func loadThumbnail(for asset: PHAsset) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        let size = CGSize(width: 300, height: 300)
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                continuation.resume(returning: result)
            }
        }
    }
}
