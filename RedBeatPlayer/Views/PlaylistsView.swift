import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var viewModel: MusicViewModel
    @State private var showCreateDialog = false
    @State private var newPlaylistName = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.blackBg.ignoresSafeArea()

                VStack(spacing: 16) {
                    if viewModel.playlists.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 48))
                                .foregroundColor(.redPrimary)
                            Text("No Playlists Yet")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.whiteSecondary)
                            Text("Tap the + button to create a playlist")
                                .font(.system(size: 13))
                                .foregroundColor(.whiteDisabled)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.playlists) { playlist in
                                PlaylistRowView(playlist: playlist)
                                    .listRowBackground(Color.blackCard)
                                    .listRowSeparatorTint(Color.blackDivider)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deletePlaylist(viewModel.playlists[index])
                                }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.blackBg)
                    }
                }
            }
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Playlists")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.whitePrimary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateDialog = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.redPrimary)
                    }
                }
            }
            .alert("Create Playlist", isPresented: $showCreateDialog) {
                TextField("Playlist name", text: $newPlaylistName)
                Button("Create") {
                    viewModel.createPlaylist(name: newPlaylistName)
                    newPlaylistName = ""
                }
                Button("Cancel", role: .cancel) {
                    newPlaylistName = ""
                }
            }
        }
    }
}

struct PlaylistRowView: View {
    let playlist: Playlist

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.redPrimary)
                    .frame(width: 48, height: 48)

                Image(systemName: "music.note.list")
                    .foregroundColor(.whitePrimary)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.whitePrimary)

                Text("\(playlist.songCount) songs")
                    .font(.system(size: 12))
                    .foregroundColor(.whiteSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.whiteDisabled)
        }
        .padding(.vertical, 4)
    }
}
