//
//  HopOnWidgetExtension.swift
//  HopOnWidgetExtension
//
//  Created by Bennet Kampe on 25/2/25.
//

import WidgetKit
import SwiftUI


struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), rotationResponse: dummyRotationResponseDefault, curBG: nil, nextBG: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, rotationResponse: dummyRotationResponseDefault, curBG: nil, nextBG: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        guard let response = try? await fetchMapRotation() else {
            let response = dummyRotationResponseDefault
            let dummyEnd = Date().addingTimeInterval(60*15)
            entries = [
                SimpleEntry(
                    date: dummyEnd,
                    configuration: configuration,
                    rotationResponse: response,
                    curBG: nil,
                    nextBG: nil,
                    error: .loadingFailed
                )
            ]
            return Timeline(entries: entries, policy: .atEnd)
        }
        var configuredResponse: ModeRotation? {
            switch configuration.gameMode.id {
            case "battle-royale":
                response.battleRoyale
            case "ranked":
                response.ranked
            default:
                response.ltm
            }
        }
        let curBG = UserDefaults(suiteName: "group.com.bk.hop-on")?.data(forKey: configuredResponse?.current.asset ?? "")
        let nextBG = UserDefaults(suiteName: "group.com.bk.hop-on")?.data(forKey: configuredResponse?.next?.asset ?? "")
        entries = [
            SimpleEntry(
                date: Date(timeIntervalSince1970: TimeInterval(configuredResponse!.current.end)),
                configuration: configuration,
                rotationResponse: response,
                curBG: curBG,
                nextBG: nextBG
            )
        ]
        if let nextResponse = configuredResponse?.next {
            entries.append(
                SimpleEntry(
                    date: Date(timeIntervalSince1970: TimeInterval(nextResponse.end)),
                    configuration: configuration,
                    rotationResponse: response,
                    curBG: nextBG,
                    nextBG: nil,
                    error: .noNext)
            )
        }
        return Timeline(entries: entries, policy: .after(Date(timeIntervalSince1970: TimeInterval(configuredResponse!.current.end))))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

enum LoadingErrorType {
    case noData
    case noNext
    case loadingFailed
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let rotationResponse: ApexMapRotationResponse
    let curBG: Data?
    let nextBG: Data?
    let error: LoadingErrorType?
    init(date: Date, configuration: ConfigurationAppIntent, rotationResponse: ApexMapRotationResponse, curBG: Data?, nextBG: Data?, error: LoadingErrorType? = nil) {
        self.date = date
        self.configuration = configuration
        self.rotationResponse = rotationResponse
        self.curBG = curBG
        self.nextBG = nextBG
        self.error = error
    }
}

struct HopOnWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    var configuredResponse: ModeRotation? {
        switch entry.configuration.gameMode.id {
        case "battle-royale":
            entry.rotationResponse.battleRoyale
        case "ranked":
            entry.rotationResponse.ranked
        default:
            entry.rotationResponse.ltm
        }
    }
    var currentResponse: RotationDetail? {
        if let configuredResponse {
            if
                TimeInterval(configuredResponse.current.end) >= entry.date.timeIntervalSince1970
                || abs(TimeInterval(configuredResponse.current.end)-entry.date.timeIntervalSince1970) < 10
            {
                return configuredResponse.current
            } else {
                return configuredResponse.next
            }
        }
        return nil
    }
    var nextResponse: RotationDetail? {
        if let configuredResponse, let next = configuredResponse.next {
            if TimeInterval(next.end) > Date().timeIntervalSince1970 && entry.error == nil {
                return configuredResponse.next
            }
        }
        return nil
    }
    var curBG: UIImage? {
        if let data = entry.curBG {
            return UIImage(data: data)!
        }
        return nil
    }
    var body: some View {
        ZStack{
            Text(entry.configuration.gameMode.title)
                .padding(.top, 4)
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading){
                if configuredResponse != nil {

                        Text("\(currentResponse?.map ?? "--")")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        if let event = currentResponse?.eventName {
                            Text("(\(event))")
                        }
                    Text(entry.date, style: .timer)
                        .monospacedDigit()
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(1, reservesSpace: true)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(Color(red: 185/255, green: 48/255, blue: 56/255))
                        )
                    HStack{
                        Text("next:")
                            .font(.footnote)
                        Group{
                            if let event = nextResponse?.eventName {
                                Text("\(nextResponse?.map ?? "--") (\(event))")
                            } else {
                                Text("\(nextResponse?.map ?? "--")")
                            }
                        }
                    }
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .font(.callout)
                }
            }
            .padding()
        }
        .fontDesign(.rounded)
        .containerBackground(for: .widget){
            if  let assetURL = URL(string: currentResponse?.asset ?? ""),
                let img = loadImageFromSharedContainer(url: assetURL),
                entry.configuration.currentMapAsBackground
            {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        ContainerRelativeShape()
                            .stroke(.black, lineWidth: 28)
                            .blur(radius: 10)
                    }
            } else {
                Rectangle()
                    .foregroundStyle(.fill)
                    .overlay {
                        ContainerRelativeShape()
                            .stroke(.black, lineWidth: 28)
                            .blur(radius: 10)
                    }
            }
        }
    }
}

struct HopOnWidgetExtension: Widget {
    let kind: String = "HopOnWidgetExtension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HopOnWidgetExtensionEntryView(entry: entry)

        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Map rotation Widget")
        .description("A widget that displays the current and next map/event rotation of a gamemode of your choice.")
    }
}

extension ConfigurationAppIntent {
    fileprivate static var br: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.gameMode = Gamemode(id: "battle_royale", title: "Battle Royale")
        return intent
    }
}

#Preview(as: .systemSmall) {
    HopOnWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .br, rotationResponse: dummyRotationResponseDefault, curBG: nil, nextBG: nil)
}
