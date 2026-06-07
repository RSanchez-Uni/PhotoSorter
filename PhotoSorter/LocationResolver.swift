//
//  LocationResolver.swift
//  PhotoSorter
//

import Foundation
import CoreLocation
import SwiftData

@ModelActor
actor LocationResolver {
    private static let rateDelayNanos: UInt64 = 1_500_000_000

    private var isCancelled = false

    func cancel() {
        isCancelled = true
    }

    func resume() {
        isCancelled = false
    }

    func resolve(prioritizedGridKeys: [String]) async {
        let geocoder = CLGeocoder()
        for gridKey in prioritizedGridKeys {
            if isCancelled { return }

            let key = gridKey
            let descriptor = FetchDescriptor<GeocodeCache>(
                predicate: #Predicate { $0.gridKey == key }
            )
            if let existing = try? modelContext.fetch(descriptor), !existing.isEmpty {
                continue
            }

            guard let coords = parseCoords(gridKey) else { continue }

            let location = CLLocation(latitude: coords.lat, longitude: coords.lng)
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let placemark = placemarks.first
                let cache = GeocodeCache(
                    gridKey: gridKey,
                    isoCountryCode: placemark?.isoCountryCode,
                    country: placemark?.country,
                    locality: placemark?.locality,
                    administrativeArea: placemark?.administrativeArea
                )
                modelContext.insert(cache)
                try? modelContext.save()
            } catch {
                let cache = GeocodeCache(gridKey: gridKey, failed: true)
                modelContext.insert(cache)
                try? modelContext.save()
            }

            try? await Task.sleep(nanoseconds: Self.rateDelayNanos)
        }
    }

    nonisolated private func parseCoords(_ gridKey: String) -> (lat: Double, lng: Double)? {
        let parts = gridKey.split(separator: "_")
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lng = Double(parts[1]) else { return nil }
        return (lat, lng)
    }
}
