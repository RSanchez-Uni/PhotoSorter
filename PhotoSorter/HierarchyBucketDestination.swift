//
//  HierarchyBucketDestination.swift
//  PhotoSorter
//

import SwiftUI

extension View {
    /// Returns the canonical drill-down destination for a `HierarchyBucket`.
    /// Leaf buckets show a photo grid; non-leaf buckets show the next hierarchy level.
    @ViewBuilder
    func bucketDestination(_ bucket: HierarchyBucket) -> some View {
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
