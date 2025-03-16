//
//  mapping.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import Foundation

// Root response struct mapping the three rotations.
struct ApexMapRotationResponse: Codable {
    let battleRoyale: ModeRotation?
    let ranked: ModeRotation?
    let ltm: ModeRotation?

    enum CodingKeys: String, CodingKey {
        case battleRoyale = "battle_royale"
        case ranked
        case ltm
    }
}

// Contains current and next rotation details for a given mode.
struct ModeRotation: Codable, Hashable {
    static func == (lhs: ModeRotation, rhs: ModeRotation) -> Bool {
        return lhs.current == rhs.current && lhs.next == rhs.next
    }

    let current: RotationDetail
    let next: RotationDetail?
}

// Details for a single rotation period.
struct RotationDetail: Codable, Hashable {
    let start: Int
    let end: Int
    let readableDateStart: String
    let readableDateEnd: String
    let map: String
    let code: String
    let durationInSecs: Int
    let durationInMinutes: Int
    let asset: String
    let remainingSecs: Int?
    let remainingMins: Int?
    let remainingTimer: String?
    let isActive: Bool?
    let eventName: String?

    enum CodingKeys: String, CodingKey {
        case start, end, map, code, asset
        case readableDateStart = "readableDate_start"
        case readableDateEnd = "readableDate_end"
        case durationInSecs = "DurationInSecs"
        case durationInMinutes = "DurationInMinutes"
        case remainingSecs, remainingMins, remainingTimer, isActive, eventName
    }
}

