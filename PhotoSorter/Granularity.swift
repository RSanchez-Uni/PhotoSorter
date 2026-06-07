//
//  Granularity.swift
//  PhotoSorter
//

import Foundation

enum TimeGranularity: String, Codable, CaseIterable, Identifiable {
    case year
    case yearMonth
    case yearMonthDay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .year: "Year"
        case .yearMonth: "Year + Month"
        case .yearMonthDay: "Year + Month + Day"
        }
    }
}

enum LocationGranularity: String, Codable, CaseIterable, Identifiable {
    case country
    case countryCity

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .country: "Country"
        case .countryCity: "Country + City"
        }
    }
}

enum BucketSortOrder: String, Codable, CaseIterable, Identifiable {
    case photoCount
    case alphabetical
    case mostRecent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .photoCount: "Photo Count"
        case .alphabetical: "Alphabetical"
        case .mostRecent: "Most Recent"
        }
    }
}
