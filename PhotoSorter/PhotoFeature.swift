//
//  PhotoFeature.swift
//  PhotoSorter
//

import Foundation
import SwiftData

@Model
final class PhotoFeature {
    @Attribute(.unique) var localIdentifier: String
    var primaryContentBucket: ContentBucket
    var alternativeContentBuckets: [ContentBucket]
    var gridCellKey: String?
    var creationDate: Date?
    var isFavorite: Bool
    var extractedAt: Date

    init(
        localIdentifier: String,
        primaryContentBucket: ContentBucket,
        alternativeContentBuckets: [ContentBucket] = [],
        gridCellKey: String? = nil,
        creationDate: Date? = nil,
        isFavorite: Bool = false,
        extractedAt: Date = .now
    ) {
        self.localIdentifier = localIdentifier
        self.primaryContentBucket = primaryContentBucket
        self.alternativeContentBuckets = alternativeContentBuckets
        self.gridCellKey = gridCellKey
        self.creationDate = creationDate
        self.isFavorite = isFavorite
        self.extractedAt = extractedAt
    }
}
