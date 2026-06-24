//
//  ContentClassifier.swift
//  PhotoSorter
//
//  Created by Robert Sanchez on 6/7/26.
//

import Foundation
import Photos
import UIKit
import Vision

struct UnmappedObservation: Sendable {
    let identifier: String
    let confidence: Float
}

struct ContentClassification: Sendable {
    let primary: ContentBucket
    let alternatives: [ContentBucket]
    let unmappedObservations: [UnmappedObservation]
}

struct ContentClassifier: Sendable {
    static let confidenceThreshold: Float = 0.5
    static let maxAlternatives: Int = 3
    static let selfieFaceAreaThreshold: CGFloat = 0.15
    static let unmappedProbeThreshold: Float = 0.3
    static let maxUnmappedReturned: Int = 5

    func classify(asset: PHAsset) async -> ContentClassification {
        if asset.mediaType == .video {
            return ContentClassification(primary: .videos, alternatives: [], unmappedObservations: [])
        }
        if asset.mediaSubtypes.contains(.photoScreenshot) {
            return ContentClassification(primary: .screenshots, alternatives: [], unmappedObservations: [])
        }

        guard let cgImage = await loadImage(for: asset) else {
            return ContentClassification(primary: .other, alternatives: [], unmappedObservations: [])
        }

        if isLikelySelfie(cgImage: cgImage) {
            return ContentClassification(primary: .selfies, alternatives: [], unmappedObservations: [])
        }

        let observations = classifyVision(cgImage: cgImage)
        return mapToBuckets(observations)
    }

    private func loadImage(for asset: PHAsset) async -> CGImage? {
        await asset.loadCGImage(targetSize: CGSize(width: 224, height: 224))
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
        var unmapped: [UnmappedObservation] = []

        for obs in observations {
            if let bucket = ContentClassMapping.bucket(for: obs.identifier) {
                bucketScores[bucket] = max(bucketScores[bucket] ?? 0, obs.confidence)
            } else if obs.confidence >= Self.unmappedProbeThreshold {
                unmapped.append(UnmappedObservation(identifier: obs.identifier, confidence: obs.confidence))
            }
        }

        let topUnmapped = Array(
            unmapped.sorted { $0.confidence > $1.confidence }.prefix(Self.maxUnmappedReturned)
        )

        let qualified = bucketScores.filter { $0.value >= Self.confidenceThreshold }
        guard !qualified.isEmpty else {
            return ContentClassification(primary: .other, alternatives: [], unmappedObservations: topUnmapped)
        }

        let sorted = qualified.sorted { $0.value > $1.value }
        let primary = sorted[0].key
        let alternatives = Array(sorted.dropFirst().prefix(Self.maxAlternatives).map(\.key))
        return ContentClassification(primary: primary, alternatives: alternatives, unmappedObservations: topUnmapped)
    }
}
