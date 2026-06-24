//
//  PHAsset+ImageLoading.swift
//  PhotoSorter
//

import Photos
import UIKit

extension PHAsset {
    /// Loads a `UIImage` for this asset using `PHImageManager`.
    func loadImage(
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFit,
        deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
        resizeMode: PHImageRequestOptionsResizeMode = .fast,
        networkAccessAllowed: Bool = true
    ) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode
        options.isNetworkAccessAllowed = networkAccessAllowed
        options.resizeMode = resizeMode

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: self,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    /// Loads a `CGImage` for this asset (used by Vision classifiers).
    func loadCGImage(
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFit,
        deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
        resizeMode: PHImageRequestOptionsResizeMode = .fast,
        networkAccessAllowed: Bool = true
    ) async -> CGImage? {
        await loadImage(
            targetSize: targetSize,
            contentMode: contentMode,
            deliveryMode: deliveryMode,
            resizeMode: resizeMode,
            networkAccessAllowed: networkAccessAllowed
        )?.cgImage
    }
}
