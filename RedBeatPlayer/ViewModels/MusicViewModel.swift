import Foundation
import Combine
import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case artist = "Artist"
    case album = "Album"
    case duration = "Duration"

    var id: String { self.rawValue }
}

class MusicViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var playlists: [Playlist] = []
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .name
    @Published var isShuffleEnabled: Bool = false
    @Published var repeatMode: Int = 0 // 0: off, 1: all, 2: one

    @Published var eqBands: [EqualizerBand] = [
        EqualizerBand(id: 0, frequency: "60Hz", gain: 0),
        EqualizerBand(id: 1, frequency: "230Hz", gain: 0),
        EqualizerBand(id: 2, frequency: "910Hz", gain: 0),
        EqualizerBand(id: 3, frequency: "3.6kHz", gain: 0),
        EqualizerBand(id: 4, frequency: "14kHz", gain: 0)
    ]
    @Published var bassBoostLevel: Float = 0
    @Published var virtualizerLevel: Float = 0

    let playerService = AudioPlayerService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadLocalSongs()
        loadDefaultPlaylists()
        bindPlayerService()
    }

    private func bindPlayerService() {
        playerService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    var filteredSongs: [Song] {
        var result = songs
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.artist.localizedCaseInsensitiveContains(searchQuery) ||
                $0.album.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        switch sortOption {
        case .name:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .artist:
            result.sort { $0.artist.localizedCompare($1.artist) == .orderedAscending }
        case .album:
            result.sort { $0.album.localizedCompare($1.album) == .orderedAscending }
        case .duration:
            result.sort { $0.duration > $1.duration }
        }
        return result
    }

    func loadLocalSongs() {
        // Look in app's Documents/Music directory for downloaded tracks
        let fileManager = FileManager.default
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let musicDir = docs.appendingPathComponent("Music", isDirectory: true)

        var loadedSongs: [Song] = []

        if let files = try? fileManager.contentsOfDirectory(at: musicDir, includingPropertiesForKeys: nil) {
            for file in files where ["mp3", "m4a", "wav", "aac", "flac"].contains(file.pathExtension.lowercased()) {
                let song = Song(
                    id: file.lastPathComponent,
                    title: file.deletingPathExtension().lastPathComponent,
                    artist: "Local Storage",
                    album: "Offline Music",
                    duration: 180,
                    fileURL: file,
                    artworkData: nil
                )
                loadedSongs.append(song)
            }
        }

        // Demo sample tracks if storage is empty
        if loadedSongs.isEmpty {
            loadedSongs = [
                Song(id: "1", title: "RedBeat Frequency", artist: "@LM7BOS", album: "Crimson Waves", duration: 214, fileURL: nil, artworkData: nil),
                Song(id: "2", title: "Midnight Pulse", artist: "@LM7BOS", album: "Dark Mode", duration: 195, fileURL: nil, artworkData: nil),
                Song(id: "3", title: "Bassline Ignition", artist: "Offline Sound", album: "Stereo Bass", duration: 245, fileURL: nil, artworkData: nil),
                Song(id: "4", title: "Neon Red Drift", artist: "SynthWave Studio", album: "RedBeat Vol 1", duration: 178, fileURL: nil, artworkData: nil)
            ]
        }

        self.songs = loadedSongs
    }

    func loadDefaultPlaylists() {
        self.playlists = [
            Playlist(id: UUID(), name: "Favorites (RedBeat)", songIds: ["1", "2"], dateCreated: Date()),
            Playlist(id: UUID(), name: "Bass Boosted", songIds: ["3"], dateCreated: Date())
        ]
    }

    func createPlaylist(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newPlaylist = Playlist(id: UUID(), name: name, songIds: [], dateCreated: Date())
        playlists.insert(newPlaylist, at: 0)
    }

    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
    }

    func play(song: Song) {
        playerService.playSong(song)
    }

    func nextSong() {
        guard let current = playerService.currentSong,
              let index = songs.firstIndex(of: current) else { return }
        let nextIndex = isShuffleEnabled ? Int.random(in: 0..<songs.count) : (index + 1) % songs.count
        play(song: songs[nextIndex])
    }

    func previousSong() {
        guard let current = playerService.currentSong,
              let index = songs.firstIndex(of: current) else { return }
        let prevIndex = (index - 1 + songs.count) % songs.count
        play(song: songs[prevIndex])
    }

    func updateEqBand(index: Int, gain: Float) {
        guard index >= 0 && index < eqBands.count else { return }
        eqBands[index].gain = gain
        playerService.setBandGain(index: index, gain: gain)
    }

    func applyPreset(name: String) {
        let presetGains: [Float]
        switch name {
        case "Bass Boost":
            presetGains = [6.0, 4.0, 1.0, 0.0, -1.0]
        case "Rock":
            presetGains = [4.5, 2.5, -1.0, 2.0, 4.0]
        case "Pop":
            presetGains = [-1.0, 1.5, 3.5, 1.0, -1.0]
        case "Vocal":
            presetGains = [-2.0, 1.0, 4.0, 2.5, 0.0]
        default: // Flat
            presetGains = [0.0, 0.0, 0.0, 0.0, 0.0]
        }

        for (i, gain) in presetGains.enumerated() {
            updateEqBand(index: i, gain: gain)
        }
    }
}
