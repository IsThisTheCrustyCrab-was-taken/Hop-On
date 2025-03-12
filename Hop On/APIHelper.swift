//
//  APIHelper.swift
//  Hop On
//
//  Created by Bennet Kampe on 23/2/25.
//

import Foundation

import Foundation
import SwiftUICore
import UIKit

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
//    let apiKey = "***REMOVED***"

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

actor ImageDownloadManager {
    static let shared = ImageDownloadManager()
    // Start with a completed task so that the first download can begin immediately.
    private var lastTask: Task<Void, Never> = Task { }

    /// Downloads an image from the given URL, ensuring that downloads happen serially.
    func downloadImage(_ url: URL) async throws -> UIImage? {
        // Capture the task representing the previous download.
        let previousTask = lastTask

        // Create a new task that waits for the previous one to finish.
        let currentTask = Task { () -> UIImage? in
            // Wait for the previous task to complete.
            await previousTask.value

            // Now perform the download.
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        }

        // Update lastTask to be a non-throwing task that waits on the current download.
        lastTask = Task {
            _ = try? await currentTask.value
        }

        // Return the image from the current download.
        return try await currentTask.value
    }
}




@Observable
class imgStore {
    var cache: [String: UIImage]
    static let shared = imgStore()
    private init() {
        self.cache = [:]
    }
}

func saveImages(_ response: ApexMapRotationResponse) async throws {
    try await saveImagesFromResponse(response, gameMode: "battle_royale")
    try await saveImagesFromResponse(response, gameMode: "ranked")
    try await saveImagesFromResponse(response, gameMode: "ltm")
}

func saveImagesFromResponse(_ response: ApexMapRotationResponse, gameMode: String) async throws {
    var selectedResponse: ModeRotation? {
        switch gameMode {
        case "battle_royale":
            return response.battleRoyale
        case "ranked":
            return response.ranked
        default:
            return response.ltm
        }
    }
    guard let selectedResponse else {return}
    let curURL = selectedResponse.current.asset
    let nextURL = selectedResponse.next?.asset

    if let url = URL(string: curURL) {
        let curIMG = try await ImageDownloadManager.shared.downloadImage(url)
        guard let curIMG else {return}
        do {
            try saveImageToSharedContainer(resizeAndCropToSquare(image: curIMG), url: url)
            print("saved \(url)")
        } catch {
            print(error.localizedDescription)
        }
    }
    if let url = URL(string: nextURL ?? "") {
        let nextIMG = try await ImageDownloadManager.shared.downloadImage(url)
        guard let nextIMG else {return}
        do {
            try saveImageToSharedContainer(resizeAndCropToSquare(image: nextIMG), url: url)
            print("saved \(url)")
        } catch {
            print(error.localizedDescription)
        }
    }
}



func resizeAndCropToSquare(image: UIImage) -> UIImage {
    let targetMaxDimension: CGFloat = 256
    let originalSize = image.size

    // Calculate the scaling factor to make the larger dimension equal to 512.
    let scaleFactor = targetMaxDimension / max(originalSize.width, originalSize.height)
    let scaledSize = CGSize(width: originalSize.width * scaleFactor,
                            height: originalSize.height * scaleFactor)

    // First, scale the image.
    let scaledRenderer = UIGraphicsImageRenderer(size: scaledSize)
    let scaledImage = scaledRenderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
    }

    // Determine the side length of the square crop (will be the smaller side of the scaled image).
    let squareLength = min(scaledSize.width, scaledSize.height)
    let cropOrigin = CGPoint(
        x: (scaledSize.width - squareLength) / 2,
        y: (scaledSize.height - squareLength) / 2
    )
    let cropRect = CGRect(origin: cropOrigin, size: CGSize(width: squareLength, height: squareLength))

    // Crop the scaled image to a square.
    let cropRenderer = UIGraphicsImageRenderer(size: CGSize(width: squareLength, height: squareLength))
    let croppedImage = cropRenderer.image { _ in
        // Draw the scaled image offset so that the desired crop rect aligns with the renderer's bounds.
        scaledImage.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
    }

    return croppedImage
}


/// Saves a UIImage as a JPEG file to the App Group’s shared container using the full URL string to determine the file name.
/// - Parameters:
///   - image: The UIImage to save.
///   - urlString: The full URL string (e.g., "https://apexlegendsstatus.com/assets/maps/Olympus.png").
/// - Throws: An error if the image data cannot be created, the URL is invalid, or the file cannot be written.
func saveImageToSharedContainer(_ image: UIImage, url: URL) throws {
    // extract the filename.
    let fileName = url.lastPathComponent

    // Convert the UIImage to JPEG data.
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        throw NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG data."])
    }

    // Get the URL for the App Group’s shared container.
    guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bk.hop-on") else {
        throw NSError(domain: "AppGroupError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access shared container."])
    }

    // Create the full file URL by appending the extracted file name.
    let fileURL = sharedContainerURL.appendingPathComponent(fileName)

    // Write the data atomically to the file system.
    try imageData.write(to: fileURL, options: .atomic)
}

/// Loads a UIImage from a file in the App Group’s shared container using the full URL string to determine the file name.
/// - Parameter urlString: The full URL string (e.g., "https://apexlegendsstatus.com/assets/maps/Olympus.png").
/// - Returns: The UIImage if it exists and is valid, or nil otherwise.
func loadImageFromSharedContainer(url: URL) -> UIImage? {
    // extract the filename.
    let fileName = url.lastPathComponent

    // Get the URL for the App Group’s shared container.
    guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bk.hop-on") else {
        return nil
    }

    // Build the file URL.
    let fileURL = sharedContainerURL.appendingPathComponent(fileName)

    // Attempt to load the data from the file.
    guard let imageData = try? Data(contentsOf: fileURL) else {
        return nil
    }

    // Create and return the UIImage.
    return UIImage(data: imageData)
}
