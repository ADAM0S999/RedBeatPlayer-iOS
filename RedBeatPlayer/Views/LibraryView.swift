import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: MusicViewModel
    @Binding var showFullPlayer: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.blackBg.ignoresSafeArea()

                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.redPrimary)
                        TextField("Search songs, artists, albums...", text: $viewModel.searchQuery)
                            .foregroundColor(.whitePrimary)
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.whiteSecondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.blackCard)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blackDivider, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Sort Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SortOption.allCases) { option in
                                Button(action: {
                                    viewModel.sortOption = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(viewModel.sortOption == option ? .whitePrimary : .whiteSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(viewModel.sortOption == option ? Color.redPrimary : Color.blackElevated)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(viewModel.sortOption == option ? Color.redPrimary : Color.clear, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Song Count
                    HStack {
                        Text("\(viewModel.filteredSongs.count) songs")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.whiteSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Song List
                    if viewModel.filteredSongs.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 48))
                                .foregroundColor(.redPrimary)
                            Text("No songs found")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.whiteSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.filteredSongs) { song in
                                SongRowView(song: song, isPlaying: viewModel.playerService.currentSong == song && viewModel.playerService.isPlaying) {
                                    viewModel.play(song: song)
                                }
                                .listRowBackground(Color.blackCard)
                                .listRowSeparatorTint(Color.blackDivider)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.blackBg)
                    }
                }
            }
            .navigationTitle("Song Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Song Library")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.whitePrimary)
                }
            }
        }
    }
}

struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Circle Art
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.redPrimary : Color.blackElevated)
                        .frame(width: 44, height: 44)
                    Image(systemName: isPlaying ? "waveform" : "music.note")
                        .foregroundColor(.whitePrimary)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(song.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isPlaying ? .redPrimary : .whitePrimary)
                        .lineLimit(1)

                    Text("\(song.artist) • \(song.album)")
                        .font(.system(size: 12))
                        .foregroundColor(.whiteSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(song.formattedDuration)
                    .font(.system(size: 12))
                    .foregroundColor(.whiteSecondary)
            }
            .padding(.vertical, 4)
        }
    }
}
