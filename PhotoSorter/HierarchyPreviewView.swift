//
//  HierarchyPreviewView.swift
//  PhotoSorter
//

import Photos
import SwiftUI

struct HierarchyPreviewView: View {
    let buckets: [HierarchyBucket]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 28) {
                ForEach(buckets) { bucket in
                    BucketSection(bucket: bucket)
                }
            }
            .padding(.vertical, 12)
        }
    }
}

private struct BucketSection: View {
    let bucket: HierarchyBucket

    private let thumbSize: CGFloat = 140
    private let leafPreviewLimit: Int = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                destination(for: bucket)
            } label: {
                sectionHeader
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    previewItems
                }
                .padding(.horizontal)
            }
        }
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(bucket.label)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(bucket.isUnknown ? Color.secondary : Color.primary)
                Text("^[\(bucket.totalPhotoCount) photo](inflect: true)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var previewItems: some View {
        if bucket.children.isEmpty {
            ForEach(Array(bucket.photoIdentifiers.prefix(leafPreviewLimit)), id: \.self) { id in
                NavigationLink {
                    PhotoDetailNavigation(identifier: id)
                } label: {
                    PhotoIdentifierThumbnail(identifier: id, size: thumbSize)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        } else {
            ForEach(bucket.children) { child in
                NavigationLink {
                    destination(for: child)
                } label: {
                    ChildBucketPreview(bucket: child, size: thumbSize)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func destination(for bucket: HierarchyBucket) -> some View {
        if bucket.isLeaf {
            BucketPhotoGrid(photoIdentifiers: bucket.photoIdentifiers)
                .navigationTitle(bucket.label)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            HierarchyPreviewView(buckets: bucket.children)
                .navigationTitle(bucket.label)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ChildBucketPreview: View {
    let bucket: HierarchyBucket
    let size: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let id = Self.firstPhotoId(in: bucket) {
                    PhotoIdentifierThumbnail(identifier: id, size: size)
                } else {
                    Color.gray.opacity(0.15)
                        .frame(width: size, height: size)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(bucket.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(bucket.isUnknown ? Color.secondary : Color.primary)
                .lineLimit(1)
                .frame(maxWidth: size, alignment: .leading)

            Text("^[\(bucket.totalPhotoCount) photo](inflect: true)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: size)
    }

    private static func firstPhotoId(in bucket: HierarchyBucket) -> String? {
        if let first = bucket.photoIdentifiers.first {
            return first
        }
        for child in bucket.children {
            if let id = firstPhotoId(in: child) {
                return id
            }
        }
        return nil
    }
}

private struct PhotoIdentifierThumbnail: View {
    let identifier: String
    let size: CGFloat

    @State private var asset: PHAsset?

    var body: some View {
        Group {
            if let asset {
                PhotoThumbnail(asset: asset)
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .frame(width: size, height: size)
        .task(id: identifier) {
            let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            asset = result.firstObject
        }
    }
}

private struct PhotoDetailNavigation: View {
    let identifier: String

    var body: some View {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject {
            PhotoDetailView(asset: asset)
        } else {
            ContentUnavailableView(
                "Photo Not Found",
                systemImage: "photo.badge.exclamationmark",
                description: Text("This photo is no longer available.")
            )
        }
    }
}
