//
//Award.swift
///
///User award is represented by # of coins earned through completing todos.  User can use the award to buy avatar part to get a new avatar
///
import Foundation

///Represents Award
///Right now Award is represented by property coin, more coins means more award.
///
struct Award: Codable {
    var coin: Int
    
    init(coin: Int) {
        self.coin = coin
    }
    
    mutating func add(award: Award) {
        self.coin += award.coin
    }
    
    mutating func minus(award: Award) {
        self.coin -= award.coin
    }
}

///Avatar entity
///An Avatar is comprised of an array of Avatarpart.
struct Avatar: Codable {
    var parts: [AvatarPart]
    
    ///convenient function to get a sample Avatar object
    static func getSampleAvatar() -> Avatar {
        return Avatar(parts: [AvatarPart(part: .head, category: .basic, index: 1),
                              AvatarPart(part: .body, category: .basic, index: 1),
                              AvatarPart(part: .bottom, category: .basic, index: 1)]
                     )
    }
}

///AvatarPart entity
///property `imageName` - respresents the image in Assets
struct AvatarPart: Hashable, Codable {
    var part: AvatarPartType
    var category: AvatarCategory
    var index: Int
    var imageName: String {"\(part.rawValue.lowercased())_\(category.rawValue.lowercased())_\(index)"}
}

enum AvatarPartType: String, CaseIterable, Codable {
    case head = "Head"
    case body = "Body"
    case bottom = "Bottom"
}

enum AvatarCategory: String, CaseIterable, Codable {
    case basic = "Basic"
    case animal = "Animal"
    case castle = "Castle"
}
