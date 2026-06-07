//
//  ContentClassMapping.swift
//  PhotoSorter
//

import Foundation

enum ContentClassMapping {
    static func bucket(for identifier: String) -> ContentBucket? {
        mapping[identifier.lowercased()]
    }

    private static let mapping: [String: ContentBucket] = [
        // Pets / animals
        "dog": .pets, "puppy": .pets, "cat": .pets, "kitten": .pets,
        "rabbit": .pets, "hamster": .pets, "guinea_pig": .pets,
        "bird": .pets, "parrot": .pets, "fish": .pets, "pet": .pets,
        "animal": .pets, "wildlife": .pets, "horse": .pets,

        // Vehicles
        "car": .vehicles, "automobile": .vehicles, "sports_car": .vehicles,
        "convertible": .vehicles, "truck": .vehicles, "pickup": .vehicles,
        "motorcycle": .vehicles, "motor_scooter": .vehicles,
        "bicycle": .vehicles, "mountain_bike": .vehicles,
        "airplane": .vehicles, "airliner": .vehicles, "helicopter": .vehicles,
        "boat": .vehicles, "ship": .vehicles, "sailboat": .vehicles,
        "yacht": .vehicles, "canoe": .vehicles, "kayak": .vehicles,
        "train": .vehicles, "locomotive": .vehicles, "subway": .vehicles,
        "bus": .vehicles, "vehicle": .vehicles,

        // Landscapes / nature
        "mountain": .landscapes, "hill": .landscapes,
        "beach": .landscapes, "coast": .landscapes,
        "ocean": .landscapes, "sea": .landscapes, "lake": .landscapes,
        "river": .landscapes, "waterfall": .landscapes,
        "forest": .landscapes, "tree": .landscapes, "woods": .landscapes,
        "flower": .landscapes, "plant": .landscapes, "garden": .landscapes,
        "sky": .landscapes, "cloud": .landscapes, "sunset": .landscapes,
        "sunrise": .landscapes, "nature": .landscapes,
        "outdoors": .landscapes, "landscape": .landscapes,
        "field": .landscapes, "valley": .landscapes, "desert": .landscapes,
        "park": .landscapes, "meadow": .landscapes,

        // Cityscapes
        "building": .cityscapes, "skyscraper": .cityscapes,
        "city": .cityscapes, "cityscape": .cityscapes,
        "street": .cityscapes, "road": .cityscapes,
        "architecture": .cityscapes, "bridge": .cityscapes,
        "tower": .cityscapes, "downtown": .cityscapes,
        "urban": .cityscapes, "monument": .cityscapes,
        "church": .cityscapes, "castle": .cityscapes,
        "lighthouse": .cityscapes,

        // Indoor scenes
        "indoors": .indoorScenes, "room": .indoorScenes,
        "kitchen": .indoorScenes, "bedroom": .indoorScenes,
        "living_room": .indoorScenes, "bathroom": .indoorScenes,
        "office": .indoorScenes, "restaurant": .indoorScenes,
        "cafe": .indoorScenes, "store": .indoorScenes,
        "shop": .indoorScenes, "interior": .indoorScenes,
        "furniture": .indoorScenes, "lecture_room": .indoorScenes,
        "library": .indoorScenes, "museum": .indoorScenes,
        "stage": .indoorScenes,

        // Food
        "food": .food, "meal": .food, "pizza": .food, "burger": .food,
        "hamburger": .food, "sandwich": .food, "hot_dog": .food,
        "drink": .food, "beverage": .food, "coffee": .food, "tea": .food,
        "wine": .food, "beer": .food, "fruit": .food, "vegetable": .food,
        "dessert": .food, "cake": .food, "ice_cream": .food,
        "bread": .food, "pasta": .food, "salad": .food,
        "soup": .food, "sushi": .food, "meat": .food, "cheese": .food,

        // Documents
        "document": .documents, "paper": .documents, "text": .documents,
        "receipt": .documents, "book": .documents, "magazine": .documents,
        "newspaper": .documents, "menu": .documents,
        "whiteboard": .documents, "letter": .documents, "form": .documents,

        // People (Portraits; Selfies handled by face heuristic)
        "person": .portraits, "people": .portraits, "face": .portraits,
        "group": .portraits, "crowd": .portraits, "portrait": .portraits,
        "child": .portraits, "baby": .portraits,
    ]
}
