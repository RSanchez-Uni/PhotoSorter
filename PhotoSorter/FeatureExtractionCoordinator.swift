//
//  FeatureExtractionCoordinator.swift
//  PhotoSorter
//
//  Created by Robert Sanchez on 6/7/26.
//

import Foundation
import Photos
import CoreLocation
import SwiftData

@ModelActor
actor FeatureExtractionCoordinator {
    private static let saveInterval = 50

    private var isCancelled = false

    #if DEBUG
    private var debugUnmappedCounts: [String: Int] = [:]
    private var debugUnmappedConfidenceSum: [String: Float] = [:]
    private var debugPrimaryCounts: [ContentBucket: Int] = [:]
    private var debugProcessedCount = 0
    #endif

    func cancel() {
        isCancelled = true
    }

    func resume() {
        isCancelled = false
    }

    func resetFeatures() async {
        let descriptor = FetchDescriptor<PhotoFeature>()
        if let existing = try? modelContext.fetch(descriptor) {
            for feature in existing {
                modelContext.delete(feature)
            }
            try? modelContext.save()
        }
    }

    func extractFeatures(for assetIdentifiers: [String]) async {
        let classifier = ContentClassifier()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        var processed = 0

        #if DEBUG
        debugUnmappedCounts.removeAll()
        debugUnmappedConfidenceSum.removeAll()
        debugPrimaryCounts.removeAll()
        debugProcessedCount = 0
        print("=== ContentClassifier probe starting (\(assets.count) candidate assets) ===")
        #endif

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

            #if DEBUG
            recordDebug(classification: classification)
            #endif

            processed += 1
            if processed % Self.saveInterval == 0 {
                try? modelContext.save()
            }
        }
        try? modelContext.save()

        #if DEBUG
        printDebugSummary()
        #endif
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

    #if DEBUG
    private func recordDebug(classification: ContentClassification) {
        debugProcessedCount += 1
        debugPrimaryCounts[classification.primary, default: 0] += 1
        for unmapped in classification.unmappedObservations {
            debugUnmappedCounts[unmapped.identifier, default: 0] += 1
            debugUnmappedConfidenceSum[unmapped.identifier, default: 0] += unmapped.confidence
        }
        let altLabels = classification.alternatives.map(\.displayName).joined(separator: ", ")
        let unmappedSummary = classification.unmappedObservations
            .map { String(format: "%@ (%.2f)", $0.identifier, $0.confidence) }
            .joined(separator: ", ")
        print("[\(debugProcessedCount)] primary=\(classification.primary.displayName) alts=[\(altLabels)] unmapped=[\(unmappedSummary)]")
    }

    private func printDebugSummary() {
        print("=== ContentClassifier probe summary ===")
        print("Processed: \(debugProcessedCount)")
        print("--- Primary bucket distribution ---")
        for bucket in ContentBucket.allCases {
            let count = debugPrimaryCounts[bucket] ?? 0
            let pct = debugProcessedCount > 0 ? (Double(count) / Double(debugProcessedCount) * 100) : 0
            print(String(format: "%5d (%5.1f%%) %@", count, pct, bucket.displayName))
        }
        print("--- Top 50 unmapped Vision identifiers ---")
        let sorted = debugUnmappedCounts.sorted { $0.value > $1.value }.prefix(50)
        for (id, count) in sorted {
            let totalConf = debugUnmappedConfidenceSum[id] ?? 0
            let avgConf = totalConf / Float(count)
            print(String(format: "%5d × %@ (avg confidence %.2f)", count, id, avgConf))
        }
        print("=======================================")
    }
    #endif
}
