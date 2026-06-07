//
//  GeocodeCache.swift
//  PhotoSorter
//

import Foundation
import SwiftData

@Model
final class GeocodeCache {
    @Attribute(.unique) var gridKey: String
    var isoCountryCode: String?
    var country: String?
    var locality: String?
    var administrativeArea: String?
    var fetchedAt: Date
    var failed: Bool

    init(
        gridKey: String,
        isoCountryCode: String? = nil,
        country: String? = nil,
        locality: String? = nil,
        administrativeArea: String? = nil,
        fetchedAt: Date = .now,
        failed: Bool = false
    ) {
        self.gridKey = gridKey
        self.isoCountryCode = isoCountryCode
        self.country = country
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.fetchedAt = fetchedAt
        self.failed = failed
    }
}
