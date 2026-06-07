//
//  FeatureExtractionCoordinator.swift
//  PhotoSorter
//

import Foundation
import Photos
import CoreLocation
import SwiftData

@ModelActor
actor FeatureExtractionCoordinator {
    private static let saveInterval = 50

    private var isCancelled = false

    func cancel() {
        isCancelled = true
    }

    func resume() {
        isCancelled = false
    }

    func extractFeatures(for assetIdentifiers: [String]) async {
        let classifier = ContentClassifier()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        var processed = 0

        for index in 0..<assets.count {
            if isCancelled { break }

            let asset = assets.object(at: index)
            let id = asset.localIdentifier

            let descriptor = FetchDescriptor<PhotoFeature>(
                predicate: #Predicate { $0.localIdentifier == id }
            )
            if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
                continue
            }

            let classification = await classifier.classify(asset: asset)
            let gridKey = asset.location.map(Self.gridKey(for:))

            let feature = PhotoFeature(
                localIdentifier: id,
                primaryContentBucket: classification.primary,
                alternativeContentBuckets: classification.alternatives,
                gridCellKey: gridKey,
                creationDate: asset.creationDate,
                isFavorite: asset.isFavorite
            )
            modelContext.insert(feature)

            processed += 1
            if processed % Self.saveInterval == 0 {
                try? modelContext.save()
            }
        }
        try? modelContext.save()
    }

    func collectGridKeyCounts(for assetIdentifiers: [String]) -> [String] {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        var counts: [String: Int] = [:]
        for index in 0..<assets.count {
            guard let location = assets.object(at: index).location else { continue }
            let key = Self.gridKey(for: location)
            counts[key, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map(\.key)
    }

    nonisolated static func gridKey(for location: CLLocation) -> String {
        let lat = (location.coordinate.latitude * 100).rounded() / 100
        let lng = (location.coordinate.longitude * 100).rounded() / 100
        return String(format: "%.2f_%.2f", lat, lng)
    }
}
