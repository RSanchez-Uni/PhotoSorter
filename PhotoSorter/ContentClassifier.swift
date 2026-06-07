//
//  ContentClassifier.swift
//  PhotoSorter
//

import Foundation
import Photos
import UIKit
import Vision

struct ContentClassification: Sendable {
    let primary: ContentBucket
    let alternatives: [ContentBucket]
}

struct ContentClassifier: Sendable {
    static let confidenceThreshold: Float = 0.6
    static let maxAlternatives: Int = 3
    static let selfieFaceAreaThreshold: CGFloat = 0.15

    func classify(asset: PHAsset) async -> ContentClassification {
        if asset.mediaType == .video {
            return ContentClassification(primary: .videos, alternatives: [])
        }
        if asset.mediaSubtypes.contains(.photoScreenshot) {
            return ContentClassification(primary: .screenshots, alternatives: [])
        }

        guard let cgImage = await loadImage(for: asset) else {
            return ContentClassification(primary: .other, alternatives: [])
        }

        if isLikelySelfie(cgImage: cgImage) {
            return ContentClassification(primary: .selfies, alternatives: [])
        }

        let observations = classifyVision(cgImage: cgImage)
        return mapToBuckets(observations)
    }

    private func loadImage(for asset: PHAsset) async -> CGImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        let size = CGSize(width: 224, height: 224)

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options
            ) { uiImage, _ in
                continuation.resume(returning: uiImage?.cgImage)
            }
        }
    }

    private func isLikelySelfie(cgImage: CGImage) -> Bool {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
        guard let faces = request.results, faces.count == 1 else { return false }
        let area = faces[0].boundingBox.width * faces[0].boundingBox.height
        return area > Self.selfieFaceAreaThreshold
    }

    private func classifyVision(cgImage: CGImage) -> [VNClassificationObservation] {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            return request.results ?? []
        } catch {
            return []
        }
    }

    private func mapToBuckets(_ observations: [VNClassificationObservation]) -> ContentClassification {
        var bucketScores: [ContentBucket: Float] = [:]
        for obs in observations {
            guard let bucket = ContentClassMapping.bucket(for: obs.identifier) else { continue }
            bucketScores[bucket] = max(bucketScores[bucket] ?? 0, obs.confidence)
        }

        let qualified = bucketScores.filter { $0.value >= Self.confidenceThreshold }
        guard !qualified.isEmpty else {
            return ContentClassification(primary: .other, alternatives: [])
        }

        let sorted = qualified.sorted { $0.value > $1.value }
        let primary = sorted[0].key
        let alternatives = Array(sorted.dropFirst().prefix(Self.maxAlternatives).map(\.key))
        return ContentClassification(primary: primary, alternatives: alternatives)
    }
}
