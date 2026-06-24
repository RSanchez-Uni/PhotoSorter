//
//  PHFetchResult+Array.swift
//  PhotoSorter
//

import Photos

extension PHFetchResult where ObjectType == PHAsset {
    /// Returns all assets in the fetch result as an `Array`.
    var allAssets: [PHAsset] {
        (0..<count).map { object(at: $0) }
    }
}
