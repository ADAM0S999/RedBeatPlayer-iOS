import Foundation
import SwiftUI

struct Song: Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let fileURL: URL?
    let artworkData: Data?

    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct Playlist: Identifiable, Hashable {
    let id: UUID
    var name: String
    var songIds: [String]
    let dateCreated: Date

    var songCount: Int {
        songIds.count
    }
}

final class DownloadItem: Identifiable, ObservableObject {
    let id: UUID
    let title: String
    let url: String
    @Published var progress: Double
    @Published var status: String
    @Published var isCompleted: Bool
    let destinationURL: URL

    init(
        id: UUID = UUID(),
        title: String,
        url: String,
        progress: Double = 0.0,
        status: String = "Queued",
        isCompleted: Bool = false,
        destinationURL: URL
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.progress = progress
        self.status = status
        self.isCompleted = isCompleted
        self.destinationURL = destinationURL
    }
}

struct EqualizerBand: Identifiable {
    let id: Int
    let frequency: String
    var gain: Float // -15 dB to +15 dB
}
