//
//  PhotoDetailView.swift
//  PhotoSorter
//

import Photos
import SwiftData
import SwiftUI

struct PhotoDetailView: View {
    let asset: PHAsset
    @Query private var matchingFeatures: [PhotoFeature]

    init(asset: PHAsset) {
        self.asset = asset
        let id = asset.localIdentifier
        self._matchingFeatures = Query(filter: #Predicate<PhotoFeature> { $0.localIdentifier == id })
    }

    private var feature: PhotoFeature? {
        matchingFeatures.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                FullPhotoView(asset: asset)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 300)

                if let feature {
                    metadataSection(feature: feature)
                }
            }
            .padding(.bottom, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func metadataSection(feature: PhotoFeature) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(feature.primaryContentBucket.displayName,
                  systemImage: feature.primaryContentBucket.systemImageName)
                .font(.headline)

            if !feature.alternativeContentBuckets.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Also matches")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(feature.alternativeContentBuckets) { bucket in
                            ContentChip(bucket: bucket)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct ContentChip: View {
    let bucket: ContentBucket

    var body: some View {
        Label(bucket.displayName, systemImage: bucket.systemImageName)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }
}

private struct FullPhotoView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .task(id: asset.localIdentifier) {
            image = await Self.load(asset: asset)
        }
    }

    private static func load(asset: PHAsset) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: 1024, height: 1024)

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options
            ) { uiImage, _ in
                continuation.resume(returning: uiImage)
            }
        }
    }
}
