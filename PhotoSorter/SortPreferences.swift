//
//  SortPreferences.swift
//  PhotoSorter
//

import Foundation
import SwiftData

@Model
final class SortPreferences {
    private var hierarchyRaw: [String]
    private var timeGranularityRaw: String
    private var locationGranularityRaw: String
    private var bucketSortOrderRaw: String
    var favoritesOnly: Bool

    init(
        hierarchy: [Dimension] = [.content, .location, .time],
        timeGranularity: TimeGranularity = .yearMonth,
        locationGranularity: LocationGranularity = .countryCity,
        bucketSortOrder: BucketSortOrder = .photoCount,
        favoritesOnly: Bool = false
    ) {
        self.hierarchyRaw = hierarchy.map(\.rawValue)
        self.timeGranularityRaw = timeGranularity.rawValue
        self.locationGranularityRaw = locationGranularity.rawValue
        self.bucketSortOrderRaw = bucketSortOrder.rawValue
        self.favoritesOnly = favoritesOnly
    }

    var hierarchy: [Dimension] {
        get {
            let decoded = hierarchyRaw.compactMap(Dimension.init(rawValue:))
            return decoded.isEmpty ? [.content, .location, .time] : decoded
        }
        set { hierarchyRaw = newValue.map(\.rawValue) }
    }

    var timeGranularity: TimeGranularity {
        get { TimeGranularity(rawValue: timeGranularityRaw) ?? .yearMonth }
        set { timeGranularityRaw = newValue.rawValue }
    }

    var locationGranularity: LocationGranularity {
        get { LocationGranularity(rawValue: locationGranularityRaw) ?? .countryCity }
        set { locationGranularityRaw = newValue.rawValue }
    }

    var bucketSortOrder: BucketSortOrder {
        get { BucketSortOrder(rawValue: bucketSortOrderRaw) ?? .photoCount }
        set { bucketSortOrderRaw = newValue.rawValue }
    }
}
