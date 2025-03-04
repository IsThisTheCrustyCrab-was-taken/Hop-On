//
//  ContentView.swift
//  Hop On
//
//  Created by Bennet Kampe on 23/2/25.
//

import SwiftUI
import WidgetKit

@Observable
class ApexMapRotation{
    var response: ApexMapRotationResponse?
    static let shared = ApexMapRotation()
    private init() {}
}


struct ContentView: View {
    @AppStorage("API_KEY", store: UserDefaults(suiteName: "group.com.bk.hop-on")) private var apiKey: String?

    @State private var apiKeyText: String = ""

    var body: some View {
        NavigationStack{
            VStack {
                if let mapRotation = ApexMapRotation.shared.response {
                    GeometryReader{ g in
                        List{
                            let types = [mapRotation.battleRoyale, mapRotation.ranked, mapRotation.ltm]
                            let typeNames: [String] = ["BR", "Ranked", "LTM"]
                            ForEach(0..<3) { i in
                                let type = types[i]
                                if let type {
                                    Section{
                                        TypeView(type: type, name: typeNames[i], refreshAction: refresh)
                                            .frame(height: g.size.height / 3.5)
                                    }
                                    
                                }
                            }
                        }
                    }
                        .frame(maxHeight: .infinity)
                        .listStyle(.plain)
                        .refreshable {
                            await refresh()
                        }
                } else {
                    if apiKey == nil {
                        TextField("Paste your API Key here...", text: $apiKeyText).onSubmit {
                            saveAPIKey()
                        }
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                    } else {
                        ProgressView("Loading...")
                            .task{
                                WidgetCenter.shared.reloadAllTimelines()
                                await refresh()}
                    }

                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }

                }
            }
        }
        .fontDesign(.rounded)

    }

    func saveAPIKey() {
        //TODO: validation
        apiKey = apiKeyText
    }

}

func refresh() async {
    do {
        ApexMapRotation.shared.response = try await fetchMapRotation()
        guard let r = ApexMapRotation.shared.response else { return }
        try await saveImages(r)
    } catch {
        print("Error fetching map rotation: \(error)")
    }
}

struct SettingsView: View {
    @AppStorage("API_KEY", store: UserDefaults(suiteName: "group.com.bk.hop-on")) private var apiKey: String?
    var body: some View {
        if let apiKey{
            Text(apiKey)
            HStack{
                Button("Remove API Key", systemImage: "trash", role: .destructive) {
                    self.apiKey = nil
                }.buttonStyle(.bordered)
                Button {
                    Task {
                        await refresh()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }.buttonStyle(.bordered)

            }
            .navigationTitle("Settings")
        }
//        ScrollView{
//            let r = ApexMapRotation.shared.response
//            if let r {
//                let types = [r.battleRoyale, r.ranked, r.ltm]
//                let d = types.flatMap { [$0?.current] + ($0?.next.map { [$0] } ?? []) }
//                let details = d.filter({$0 != nil})
//                ForEach(details, id: \.self) { detail in
//                    let img = UserDefaults(suiteName: "group.com.bk.hop-on")?.data(forKey: detail!.asset)
//                    if let img {
//                        Image(uiImage: UIImage(data: img)!)
//
//                    } else {
//                        Text("Loading...")
//                    }
//                }
//            }
//        }
    }
}

struct TypeView: View {
    let type: ModeRotation
    let name: String
    let refreshAction: () async -> Void
    var body: some View {
        let current = type.current
        let next = type.next
        VStack {
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Group{
                if let url = URL(string: current.asset) {
                    AsyncImage(url: url) { img in
                        TypeImageView(type: current, image: img, refreshAction: refreshAction)
                            .frame(maxHeight: .infinity)
                    } placeholder: {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    }

                } else {
                    Rectangle().foregroundStyle(.gray.gradient)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            HStack(){
                Text("Next: ")
                if let next {
                    Text("\(next.map)")
                    if let eventName = next.eventName {
                        Spacer()
                        Text("(\(eventName))")
                    }
                }
            }
            .fontWeight(.medium)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity)

    }
}

struct CountdownTextField: View {
    /// The target date to count down to.
    let targetDate: Date
    /// Callback to refresh data when the countdown reaches zero.
    var onTimerComplete: (() -> Void)? = nil

    /// The remaining time in seconds.
    @State private var timeLeft: TimeInterval = 0
    /// Flag to ensure we only trigger the refresh once per cycle.
    @State private var didTriggerRefresh = false

    /// A timer that fires every second.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Formats the remaining time into a string such as "1d 02h 05m 09s"
    func formattedTime(from interval: TimeInterval) -> String {
        guard interval > 0 else { return "0s" }
        let totalSeconds = Int(interval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var components: [String] = []
        if days > 0 {
            // Days are shown without padding.
            components.append("\(days)d")
            // With days, pad hours, minutes, and seconds to 2 digits.
            components.append(String(format: "%02dh", hours))
            components.append(String(format: "%02dm", minutes))
            components.append(String(format: "%02ds", seconds))
        } else if hours > 0 {
            components.append("\(hours)h")
            components.append(String(format: "%02dm", minutes))
            components.append(String(format: "%02ds", seconds))
        } else if minutes > 0 {
            components.append("\(minutes)m")
            components.append(String(format: "%02ds", seconds))
        } else {
            components.append("\(seconds)s")
        }
        return components.joined(separator: " ")
    }

    var body: some View {
        Text(formattedTime(from: timeLeft))
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.center)
            .disabled(true)  // Makes the field read-only
            .onReceive(timer) { _ in
                let now = Date()
                timeLeft = targetDate.timeIntervalSince(now)
                if timeLeft <= 0 {
                    timeLeft = 0
                    if !didTriggerRefresh {
                        didTriggerRefresh = true
                        onTimerComplete?()
                    }
                } else {
                    didTriggerRefresh = false
                }
            }
            .padding()
    }
}

struct TypeImageView: View {
    let type: RotationDetail
    let image: Image
    let refreshAction: () async -> Void
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .overlay {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }

            VStack(alignment: .leading){
                HStack {
                    Text(type.map)
                    Spacer()
                    CountdownTextField(targetDate: Date(timeIntervalSince1970: TimeInterval(type.end)), onTimerComplete:{ Task {
                        await refreshAction()
                    }})
                }
                Spacer()
                if let eventName = type.eventName {
                    Text(eventName)
                }
            }
            .fontWeight(.heavy)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    ContentView()
}
