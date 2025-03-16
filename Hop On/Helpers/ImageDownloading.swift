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
    try await saveImageForGameMode(response, gameMode: "battle_royale")
    try await saveImageForGameMode(response, gameMode: "ranked")
    try await saveImageForGameMode(response, gameMode: "ltm")
}

func saveImageForGameMode(_ response: ApexMapRotationResponse, gameMode: String) async throws {
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

    if let url = URL(string: curURL), !imageExistsInSharedContainer(url: url){
        let curIMG = try await ImageDownloadManager.shared.downloadImage(url)
        guard let curIMG else {return}
        do {
            try saveImageToSharedContainer(resizeAndCropToSquare(image: curIMG), url: url)
            print("saved \(url)")
        } catch {
            print(error.localizedDescription)
        }
    }
    if let url = URL(string: nextURL ?? ""), !imageExistsInSharedContainer(url: url){
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

func imageExistsInSharedContainer(url: URL) -> Bool {
    let fileName = url.lastPathComponent
    
    guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bk.hop-on") else {
        return false
    }
    return true
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
