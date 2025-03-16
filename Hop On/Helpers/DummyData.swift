//
//  DummyData.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import Foundation

let dummyRotationDefault: RotationDetail = .init(
    start: 1608457600,
    end: 1740447000,
    readableDateStart: "2021-02-23T00:00:00Z",
    readableDateEnd: "2021-02-24T00:00:00Z",
    map: "Placeholder",
    code: "DOR",
    durationInSecs: 3600,
    durationInMinutes: 60,
    asset: "https://apexlegendsstatus.com/assets/maps/Olympus.png",
    remainingSecs: 61475,
    remainingMins: 1025,
    remainingTimer: "17:04:35",
    isActive: nil,
    eventName: nil
)

let dummyRotationDefaultFuture: RotationDetail = .init(
    start: 1608457600,
    end: 6961788000,
    readableDateStart: "2021-02-23T00:00:00Z",
    readableDateEnd: "2021-02-24T00:00:00Z",
    map: "Placeholder",
    code: "DOR",
    durationInSecs: 3600,
    durationInMinutes: 60,
    asset: "https://apexlegendsstatus.com/assets/maps/Olympus.png",
    remainingSecs: 61475,
    remainingMins: 1025,
    remainingTimer: "17:04:35",
    isActive: nil,
    eventName: nil
)

let dummyRotationLTM: RotationDetail = .init(
    start: 1608457600,
    end: 1740447000,
    readableDateStart: "2021-02-23T00:00:00Z",
    readableDateEnd: "2021-02-24T00:00:00Z",
    map: "Placeholder",
    code: "DOR",
    durationInSecs: 3600,
    durationInMinutes: 60,
    asset: "https://apexlegendsstatus.com/assets/maps/Olympus.png",
    remainingSecs: 61475,
    remainingMins: 1025,
    remainingTimer: "17:04:35",
    isActive: nil,
    eventName: "Fontknight"
)

let dummyRotationLTMFuture: RotationDetail = .init(
    start: 1608457600,
    end: 6961788000,
    readableDateStart: "2021-02-23T00:00:00Z",
    readableDateEnd: "2021-02-24T00:00:00Z",
    map: "Placeholder",
    code: "DOR",
    durationInSecs: 3600,
    durationInMinutes: 60,
    asset: "https://apexlegendsstatus.com/assets/maps/Olympus.png",
    remainingSecs: 61475,
    remainingMins: 1025,
    remainingTimer: "17:04:35",
    isActive: nil,
    eventName: "Fontknight"
)

let dummyModeRotationDefault: ModeRotation = .init(
    current: dummyRotationDefault,
    next: dummyRotationDefaultFuture
)



let dummyRotationResponseDefault: ApexMapRotationResponse = .init(
    battleRoyale: dummyModeRotationDefault,
    ranked: dummyModeRotationDefault,
    ltm: .init(current: dummyRotationLTM, next: dummyRotationLTMFuture)
)
