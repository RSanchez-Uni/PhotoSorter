//
//  ContentBucket.swift
//  PhotoSorter
//

import Foundation

enum ContentBucket: String, Codable, CaseIterable, Identifiable {
    case selfies
    case portraits
    case pets
    case landscapes
    case cityscapes
    case indoorScenes
    case food
    case documents
    case screenshots
    case videos
    case vehicles
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .selfies: "Selfies"
        case .portraits: "Portraits"
        case .pets: "Pets"
        case .landscapes: "Landscapes"
        case .cityscapes: "Cityscapes"
        case .indoorScenes: "Indoor Scenes"
        case .food: "Food"
        case .documents: "Documents"
        case .screenshots: "Screenshots"
        case .videos: "Videos"
        case .vehicles: "Vehicles"
        case .other: "Other"
        }
    }

    var systemImageName: String {
        switch self {
        case .selfies: "person.crop.circle"
        case .portraits: "person.2"
        case .pets: "pawprint"
        case .landscapes: "mountain.2"
        case .cityscapes: "building.2"
        case .indoorScenes: "house"
        case .food: "fork.knife"
        case .documents: "doc"
        case .screenshots: "iphone"
        case .videos: "video"
        case .vehicles: "car"
        case .other: "questionmark"
        }
    }
}
