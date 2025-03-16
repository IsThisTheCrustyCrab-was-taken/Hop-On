//
//  CountdownTextField.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import SwiftUI

struct CountdownTextField: View {
    /// The target date to count down to.
    let targetDate: Date
    /// Callback to refresh data when the countdown reaches zero.
    var onTimerComplete: (() -> Void)? = nil

    /// The remaining time in seconds.
    @State private var timeLeft: TimeInterval = 0
    /// Flag to ensure we only trigger the refresh once per cycle.
    @State private var didTriggerRefresh = false
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
