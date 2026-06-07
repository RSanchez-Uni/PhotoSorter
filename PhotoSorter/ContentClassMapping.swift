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
        "adult_cat": .pets, "young_cat": .pets, "adult_dog": .pets, "young_dog": .pets,

        // Vehicles
        "car": .vehicles, "automobile": .vehicles, "sports_car": .vehicles,
        "convertible": .vehicles, "truck": .vehicles, "pickup": .vehicles,
        "motorcycle": .vehicles, "motor_scooter": .vehicles,
        "bicycle": .vehicles, "mountain_bike": .vehicles,
        "airplane": .vehicles, "airliner": .vehicles, "aircraft": .vehicles,
        "helicopter": .vehicles, "boat": .vehicles, "ship": .vehicles,
        "sailboat": .vehicles, "yacht": .vehicles, "canoe": .vehicles,
        "kayak": .vehicles, "train": .vehicles, "locomotive": .vehicles,
        "subway": .vehicles, "bus": .vehicles, "vehicle": .vehicles,
        "machine": .vehicles, "conveyance": .vehicles,
        "wheel": .vehicles, "tire": .vehicles, "rim": .vehicles,
        "sportscar": .vehicles, "license_plate": .vehicles,
        "dashboard": .vehicles, "porthole": .vehicles,

        // Landscapes / nature
        "mountain": .landscapes, "hill": .landscapes,
        "beach": .landscapes, "coast": .landscapes,
        "ocean": .landscapes, "sea": .landscapes, "lake": .landscapes,
        "river": .landscapes, "waterfall": .landscapes, "water": .landscapes,
        "water_body": .landscapes,
        "forest": .landscapes, "tree": .landscapes, "woods": .landscapes,
        "flower": .landscapes, "plant": .landscapes, "garden": .landscapes,
        "sky": .landscapes, "blue_sky": .landscapes, "night_sky": .landscapes,
        "cloud": .landscapes, "cloudy": .landscapes,
        "sunset": .landscapes, "sunrise": .landscapes, "nature": .landscapes,
        "outdoor": .landscapes, "outdoors": .landscapes, "landscape": .landscapes,
        "land": .landscapes, "grass": .landscapes, "rocks": .landscapes,
        "field": .landscapes, "valley": .landscapes, "desert": .landscapes,
        "park": .landscapes, "meadow": .landscapes,
        "shrub": .landscapes, "foliage": .landscapes, "palm_tree": .landscapes,
        "sunset_sunrise": .landscapes, "celestial_body": .landscapes,
        "wood_natural": .landscapes, "moon": .landscapes, "underwater": .landscapes,
        "branch": .landscapes, "farm": .landscapes, "agriculture": .landscapes,

        // Cityscapes
        "building": .cityscapes, "skyscraper": .cityscapes,
        "city": .cityscapes, "cityscape": .cityscapes,
        "street": .cityscapes, "road": .cityscapes,
        "architecture": .cityscapes, "bridge": .cityscapes,
        "tower": .cityscapes, "downtown": .cityscapes,
        "urban": .cityscapes, "monument": .cityscapes,
        "church": .cityscapes, "castle": .cityscapes,
        "lighthouse": .cityscapes,
        "structure": .cityscapes, "arch": .cityscapes,
        "fence": .cityscapes, "portal": .cityscapes, "sign": .cityscapes,
        "brick": .cityscapes, "dome": .cityscapes, "sidewalk": .cityscapes,
        "lamppost": .cityscapes, "path": .cityscapes,
        "escalator": .cityscapes, "storefront": .cityscapes,

        // Indoor scenes
        "indoors": .indoorScenes, "room": .indoorScenes, "interior_room": .indoorScenes,
        "kitchen": .indoorScenes, "bedroom": .indoorScenes,
        "living_room": .indoorScenes, "bathroom": .indoorScenes,
        "office": .indoorScenes, "restaurant": .indoorScenes,
        "cafe": .indoorScenes, "store": .indoorScenes,
        "shop": .indoorScenes, "interior": .indoorScenes,
        "furniture": .indoorScenes, "lecture_room": .indoorScenes,
        "library": .indoorScenes, "museum": .indoorScenes,
        "stage": .indoorScenes,
        "table": .indoorScenes, "window": .indoorScenes,
        "frame": .indoorScenes, "decoration": .indoorScenes,
        "wood_processed": .indoorScenes,
        "sofa": .indoorScenes, "cabinet": .indoorScenes,
        "interior_shop": .indoorScenes, "classroom": .indoorScenes,
        "bookshelf": .indoorScenes, "chandelier": .indoorScenes,
        "door": .indoorScenes, "stairs": .indoorScenes,
        "appliance": .indoorScenes, "bedding": .indoorScenes,
        "curtain": .indoorScenes, "seat": .indoorScenes,
        "television": .indoorScenes, "chalkboard": .indoorScenes,

        // Food
        "food": .food, "meal": .food, "pizza": .food, "burger": .food,
        "hamburger": .food, "sandwich": .food, "hot_dog": .food,
        "drink": .food, "beverage": .food, "coffee": .food, "tea": .food,
        "wine": .food, "beer": .food, "fruit": .food, "vegetable": .food,
        "dessert": .food, "cake": .food, "ice_cream": .food,
        "bread": .food, "pasta": .food, "salad": .food,
        "soup": .food, "sushi": .food, "meat": .food, "cheese": .food,
        "utensil": .food, "tableware": .food, "plate": .food,
        "bowl": .food, "liquid": .food, "drinking_glass": .food, "bottle": .food,
        "cup": .food, "cookware": .food, "pan": .food, "fries": .food,
        "egg": .food, "straw_drinking": .food,
        "spaghetti": .food, "fork": .food, "spoon": .food, "stove": .food,
        "pot_cooking": .food, "fried_egg": .food, "housewares": .food,

        // Documents
        "document": .documents, "paper": .documents, "text": .documents,
        "receipt": .documents, "book": .documents, "magazine": .documents,
        "newspaper": .documents, "menu": .documents,
        "whiteboard": .documents, "letter": .documents, "form": .documents,
        "handwriting": .documents, "printed_page": .documents,
        "office_supplies": .documents, "art": .documents, "illustrations": .documents,
        "calendar": .documents, "computer_keyboard": .documents,

        // Screenshots (fallback for assets without the photoScreenshot subtype)
        "screenshot": .screenshots, "computer_monitor": .screenshots,

        // People (Portraits; Selfies handled by face heuristic)
        "person": .portraits, "people": .portraits, "face": .portraits,
        "group": .portraits, "crowd": .portraits, "portrait": .portraits,
        "child": .portraits, "baby": .portraits, "adult": .portraits,
        "clothing": .portraits, "suit": .portraits,
        "necktie": .portraits, "jacket": .portraits,
        "sunglasses": .portraits, "eyeglasses": .portraits,
        "jeans": .portraits, "headgear": .portraits,
        "ceremony": .portraits, "graduation": .portraits, "celebration": .portraits,
        "gown": .portraits, "hat": .portraits, "baseball_hat": .portraits, "toy": .portraits,
        "musical_instrument": .portraits, "guitar": .portraits,
        "music": .portraits, "string_instrument": .portraits,
    ]
}
