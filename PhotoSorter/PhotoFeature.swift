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
    var primaryPersonName: String?
    var alternativePersonNames: [String]
    var isFavorite: Bool
    var extractedAt: Date

    init(
        localIdentifier: String,
        primaryContentBucket: ContentBucket,
        alternativeContentBuckets: [ContentBucket] = [],
        gridCellKey: String? = nil,
        creationDate: Date? = nil,
        primaryPersonName: String? = nil,
        alternativePersonNames: [String] = [],
        isFavorite: Bool = false,
        extractedAt: Date = .now
    ) {
        self.localIdentifier = localIdentifier
        self.primaryContentBucket = primaryContentBucket
        self.alternativeContentBuckets = alternativeContentBuckets
        self.gridCellKey = gridCellKey
        self.creationDate = creationDate
        self.primaryPersonName = primaryPersonName
        self.alternativePersonNames = alternativePersonNames
        self.isFavorite = isFavorite
        self.extractedAt = extractedAt
    }
}
