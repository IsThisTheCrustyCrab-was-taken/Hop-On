//
//  SettingsView.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("API_KEY", store: UserDefaults(suiteName: "group.com.bk.hop-on")) private var apiKey: String?
    @State private var apiResponse: String? = nil
    var body: some View {
        if let apiKey{
            Text(apiKey)
            VStack {
                HStack{
                    Button("Remove API Key", systemImage: "trash", role: .destructive) {
                        self.apiKey = nil
                    }.buttonStyle(.bordered)
                }

                Section("Debug"){
                    Button {
                        Task {
                            apiResponse = try? await fetchMapRotationDebug()
                        }
                    } label: {
                        Text("Get\(apiResponse != nil ? " new " : " " )api response")
                            .animation(.bouncy, value: apiResponse)
                    }
                    .buttonStyle(.bordered )
                    if let apiResponse {
                        ScrollView {
                            Text(apiResponse)
                        }
                        .animation(.easeInOut, value: apiResponse)
                    }
                }.padding(.top)
            }
            .navigationTitle("Settings")
        }
    }
}
