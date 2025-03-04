//
//  AppIntent.swift
//  HopOnWidgetExtension
//
//  Created by Bennet Kampe on 25/2/25.
//

import WidgetKit
import AppIntents

struct GameModeQuery: EntityQuery {
    func entities(for identifiers: [Gamemode.ID]) async throws -> [Gamemode] {
        Gamemode.allCases.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [Gamemode] {
        Gamemode.allCases
    }

    func defaultResult() async -> Gamemode? {
        try? await suggestedEntities().first
    }
}

struct Gamemode: AppEntity {
    static var defaultQuery = GameModeQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Gamemode"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    let id: String
    let title: String

    static let allCases: [Gamemode] = [
        Gamemode(id: "battle_royale", title: "Battle Royale"),
        Gamemode(id: "ranked", title: "Ranked"),
        Gamemode(id: "ltm", title: "LTM")
        ]


}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Choose a Gamemode to display" }

    // An example configurable parameter.

    @Parameter(title: "Gamemode", default: Gamemode(id: "battle_royale", title: "Battle Royale"),)
    var gameMode: Gamemode
    @Parameter(title: "Current map as background", default: true)
    var currentMapAsBackground: Bool
}
