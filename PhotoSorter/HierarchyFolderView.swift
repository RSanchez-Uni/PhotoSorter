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
                    bucketDestination(bucket)
                } label: {
                    BucketRow(bucket: bucket)
                }
            }
        }
        .listStyle(.insetGrouped)
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
