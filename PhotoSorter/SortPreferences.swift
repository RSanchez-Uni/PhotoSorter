//
//  SortPreferences.swift
//  PhotoSorter
//

import Foundation
import SwiftData

@Model
final class SortPreferences {
    var hierarchy: [Dimension]
    var timeGranularity: TimeGranularity
    var locationGranularity: LocationGranularity
    var bucketSortOrder: BucketSortOrder
    var favoritesOnly: Bool

    init(
        hierarchy: [Dimension] = [.content, .location, .time, .people],
        timeGranularity: TimeGranularity = .yearMonth,
        locationGranularity: LocationGranularity = .countryCity,
        bucketSortOrder: BucketSortOrder = .photoCount,
        favoritesOnly: Bool = false
    ) {
        self.hierarchy = hierarchy
        self.timeGranularity = timeGranularity
        self.locationGranularity = locationGranularity
        self.bucketSortOrder = bucketSortOrder
        self.favoritesOnly = favoritesOnly
    }
}
