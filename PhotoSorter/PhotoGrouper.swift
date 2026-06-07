//
//  PhotoGrouper.swift
//  PhotoSorter
//

import Foundation

struct HierarchyBucket: Identifiable {
    let id: String
    let label: String
    let photoIdentifiers: [String]
    let children: [HierarchyBucket]
    let maxCreationDate: Date?
    let isUnknown: Bool

    var totalPhotoCount: Int {
        if children.isEmpty {
            return photoIdentifiers.count
        }
        return children.reduce(0) { $0 + $1.totalPhotoCount }
    }

    var isLeaf: Bool { children.isEmpty }
}

struct PhotoGrouper {
    let features: [PhotoFeature]
    let cacheByKey: [String: GeocodeCache]
    let prefs: SortPreferences

    func build() -> [HierarchyBucket] {
        let filtered = prefs.favoritesOnly ? features.filter(\.isFavorite) : features
        let tiers = expandedTiers()
        guard !tiers.isEmpty else {
            return [
                HierarchyBucket(
                    id: "all",
                    label: "All Photos",
                    photoIdentifiers: filtered.map(\.localIdentifier),
                    children: [],
                    maxCreationDate: filtered.compactMap(\.creationDate).max(),
                    isUnknown: false
                ),
            ]
        }
        return group(features: filtered, tiers: tiers)
    }

    private func expandedTiers() -> [Tier] {
        var tiers: [Tier] = []
        for dim in prefs.hierarchy {
            switch dim {
            case .content:
                tiers.append(.content)
            case .location:
                tiers.append(.country)
                if prefs.locationGranularity == .countryCity {
                    tiers.append(.city)
                }
            case .time:
                tiers.append(.year)
                if prefs.timeGranularity == .yearMonth || prefs.timeGranularity == .yearMonthDay {
                    tiers.append(.month)
                }
                if prefs.timeGranularity == .yearMonthDay {
                    tiers.append(.day)
                }
            }
        }
        return tiers
    }

    private func group(features: [PhotoFeature], tiers: [Tier]) -> [HierarchyBucket] {
        guard let tier = tiers.first else { return [] }
        let remaining = Array(tiers.dropFirst())

        var bucketFeatures: [String: [PhotoFeature]] = [:]
        var bucketLabels: [String: String] = [:]
        var bucketUnknown: [String: Bool] = [:]

        for feature in features {
            let assignment = tier.groupKey(for: feature, cacheByKey: cacheByKey)
            bucketFeatures[assignment.key, default: []].append(feature)
            bucketLabels[assignment.key] = assignment.label
            bucketUnknown[assignment.key] = assignment.unknown
        }

        let buckets = bucketFeatures.map { (key, group) -> HierarchyBucket in
            let label = bucketLabels[key] ?? key
            let unknown = bucketUnknown[key] ?? false
            let maxDate = group.compactMap(\.creationDate).max()
            if remaining.isEmpty {
                return HierarchyBucket(
                    id: key,
                    label: label,
                    photoIdentifiers: group.map(\.localIdentifier),
                    children: [],
                    maxCreationDate: maxDate,
                    isUnknown: unknown
                )
            } else {
                let children = self.group(features: group, tiers: remaining)
                return HierarchyBucket(
                    id: key,
                    label: label,
                    photoIdentifiers: [],
                    children: children,
                    maxCreationDate: maxDate,
                    isUnknown: unknown
                )
            }
        }

        return sortBuckets(buckets)
    }

    private func sortBuckets(_ buckets: [HierarchyBucket]) -> [HierarchyBucket] {
        let known = buckets.filter { !$0.isUnknown }
        let unknown = buckets.filter { $0.isUnknown }

        let sortedKnown: [HierarchyBucket]
        switch prefs.bucketSortOrder {
        case .photoCount:
            sortedKnown = known.sorted { $0.totalPhotoCount > $1.totalPhotoCount }
        case .alphabetical:
            sortedKnown = known.sorted { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
        case .mostRecent:
            sortedKnown = known.sorted { ($0.maxCreationDate ?? .distantPast) > ($1.maxCreationDate ?? .distantPast) }
        }
        return sortedKnown + unknown
    }
}

private enum Tier {
    case content
    case country
    case city
    case year
    case month
    case day

    func groupKey(for feature: PhotoFeature, cacheByKey: [String: GeocodeCache]) -> (key: String, label: String, unknown: Bool) {
        switch self {
        case .content:
            let bucket = feature.primaryContentBucket
            return ("content_\(bucket.rawValue)", bucket.displayName, bucket == .other)

        case .country:
            guard let gridKey = feature.gridCellKey,
                  let cache = cacheByKey[gridKey],
                  let isoCode = cache.isoCountryCode,
                  !isoCode.isEmpty else {
                return ("unknown_country", "Unknown Location", true)
            }
            let label = cache.country ?? isoCode
            return ("country_\(isoCode)", label, false)

        case .city:
            guard let gridKey = feature.gridCellKey, let cache = cacheByKey[gridKey] else {
                return ("unknown_city", "Unknown City", true)
            }
            if let locality = cache.locality, !locality.isEmpty {
                return ("city_\(locality)", locality, false)
            }
            if let admin = cache.administrativeArea, !admin.isEmpty {
                return ("admin_\(admin)", admin, false)
            }
            return ("unknown_city", "Unknown City", true)

        case .year:
            guard let date = feature.creationDate else {
                return ("unknown_year", "Unknown Year", true)
            }
            let year = Calendar.current.component(.year, from: date)
            return ("year_\(year)", "\(year)", false)

        case .month:
            guard let date = feature.creationDate else {
                return ("unknown_month", "Unknown Month", true)
            }
            let month = Calendar.current.component(.month, from: date)
            let monthSymbols = DateFormatter().monthSymbols ?? []
            let name = (1...12).contains(month) ? monthSymbols[month - 1] : "\(month)"
            return ("month_\(month)", name, false)

        case .day:
            guard let date = feature.creationDate else {
                return ("unknown_day", "Unknown Day", true)
            }
            let day = Calendar.current.component(.day, from: date)
            return ("day_\(day)", "\(day)", false)
        }
    }
}
