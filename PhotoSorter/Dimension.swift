//
//  Dimension.swift
//  PhotoSorter
//

import Foundation

enum Dimension: String, Codable, Identifiable, CaseIterable {
    case content
    case location
    case time

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .content: "Content"
        case .location: "Location"
        case .time: "Time"
        }
    }

    var systemImageName: String {
        switch self {
        case .content: "photo.stack"
        case .location: "mappin.and.ellipse"
        case .time: "calendar"
        }
    }
}
