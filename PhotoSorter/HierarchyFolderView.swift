//
//  HierarchyFolderView.swift
//  PhotoSorter
//

import SwiftUI

struct HierarchyFolderView: View {
    let buckets: [HierarchyBucket]

    var body: some View {
        List {
            ForEach(buckets) { bucket in
                NavigationLink {
                    destination(for: bucket)
                } label: {
                    BucketRow(bucket: bucket)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func destination(for bucket: HierarchyBucket) -> some View {
        if bucket.isLeaf {
            BucketPhotoGrid(photoIdentifiers: bucket.photoIdentifiers)
                .navigationTitle(bucket.label)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            HierarchyFolderView(buckets: bucket.children)
                .navigationTitle(bucket.label)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct BucketRow: View {
    let bucket: HierarchyBucket

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: bucket.isUnknown ? "questionmark.folder" : "folder.fill")
                .foregroundStyle(bucket.isUnknown ? Color.secondary : Color.accentColor)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(bucket.label)
                Text("^[\(bucket.totalPhotoCount) photo](inflect: true)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
