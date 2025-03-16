//
//  APIError.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import Foundation

@Observable
class ApexMapRotation{
    var response: ApexMapRotationResponse?
    static let shared = ApexMapRotation()
    private init() {}
}


enum APIError: Error {
    case missingAPIKey
    case invalidURL
}

func fetchMapRotation() async throws -> ApexMapRotationResponse {
    // Retrieve your API key from AppStorage or your preferred storage method
//    guard let apiKey = UserDefaults.standard.string(forKey: "API_KEY"), !apiKey.isEmpty else {
//        throw APIError.missingAPIKey
//    }
    guard let apiKey = UserDefaults(suiteName: "group.com.bk.hop-on")?.string(forKey: "API_KEY"), !apiKey.isEmpty else {
        throw APIError.missingAPIKey
    }

    // Build the URL string with version=2
    let urlString = "https://api.mozambiquehe.re/maprotation?auth=\(apiKey)&version=2"
    guard let url = URL(string: urlString) else {
        throw APIError.invalidURL
    }

    // Fetch the data
    let (data, _) = try await URLSession.shared.data(from: url)
    // Decode the JSON into our MapRotation model
    let decoder = JSONDecoder()
    let rotationResponse = try decoder.decode(ApexMapRotationResponse.self, from: data)
    return rotationResponse
}
