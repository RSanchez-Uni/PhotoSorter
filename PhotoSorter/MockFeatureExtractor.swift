//
//  MockFeatureExtractor.swift
//  PhotoSorter
//

import Foundation
import Photos

enum MockFeatureExtractor {
    private static let mockGridCells: [(gridKey: String, iso: String, country: String, locality: String, admin: String)] = [
        ("33.62_-117.93", "US", "United States", "Newport Beach", "California"),
        ("40.71_-74.01", "US", "United States", "New York", "New York"),
        ("41.89_12.49", "IT", "Italy", "Rome", "Lazio"),
        ("35.68_139.69", "JP", "Japan", "Tokyo", "Tokyo"),
        ("21.16_-86.85", "MX", "Mexico", "Cancún", "Quintana Roo"),
        ("48.86_2.29", "FR", "France", "Paris", "Île-de-France"),
    ]

    static func extractFeature(for asset: PHAsset) -> PhotoFeature {
        let primary = ContentBucket.allCases.randomElement() ?? .other
        let alternatives = ContentBucket.allCases
            .filter { $0 != primary }
            .shuffled()
            .prefix(Int.random(in: 0...3))

        let location = mockGridCells.randomElement()

        return PhotoFeature(
            localIdentifier: asset.localIdentifier,
            primaryContentBucket: primary,
            alternativeContentBuckets: Array(alternatives),
            gridCellKey: location?.gridKey,
            creationDate: asset.creationDate,
            isFavorite: asset.isFavorite
        )
    }

    static func mockGeocodeCache(for gridKey: String) -> GeocodeCache? {
        guard let entry = mockGridCells.first(where: { $0.gridKey == gridKey }) else { return nil }
        return GeocodeCache(
            gridKey: entry.gridKey,
            isoCountryCode: entry.iso,
            country: entry.country,
            locality: entry.locality,
            administrativeArea: entry.admin
        )
    }
}
