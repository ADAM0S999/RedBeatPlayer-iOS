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

struct DownloadItem: Identifiable, ObservableObject {
    let id: UUID
    let title: String
    let url: String
    @Published var progress: Double = 0.0
    @Published var status: String = "Queued"
    @Published var isCompleted: BooleanLiteralType = false
    let destinationURL: URL
}

struct EqualizerBand: Identifiable {
    let id: Int
    let frequency: String
    var gain: Float // -15 dB to +15 dB
}
