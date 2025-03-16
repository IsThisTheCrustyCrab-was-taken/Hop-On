//
//  ContentView.swift
//  Hop On
//
//  Created by Bennet Kampe on 23/2/25.
//

import SwiftUI
import WidgetKit


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
                        HStack {
                            Text("Create an API Key ")
                            Link("Here", destination: URL(string: "https://portal.apexlegendsapi.com")!)
                        }
                        Text("Please do mention Hop-On in the key's description")
                            .font(.caption)
                        TextField("Paste your API Key here...", text: $apiKeyText).onSubmit {
                            saveAPIKey()
                        }
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .padding(.horizontal)
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




/// A timer that fires every second.
let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()



#Preview {
    ContentView()
}
