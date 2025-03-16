//
//  SettingsView.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import SwiftUI

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
    }
}
