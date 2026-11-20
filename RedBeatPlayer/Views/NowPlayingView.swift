import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var viewModel: MusicViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showEqualizer = false
    @State private var isSeeking = false
    @State private var seekTime: Double = 0

    var body: some View {
        ZStack {
            // Background Gradient: Black to Deep Crimson Red
            LinearGradient(
                gradient: Gradient(colors: [Color.blackBg, Color.blackSurface, Color.redDark.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.whitePrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("NOW PLAYING")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.redPrimary)

                        if let song = viewModel.playerService.currentSong {
                            Text(song.album)
                                .font(.system(size: 12))
                                .foregroundColor(.whiteSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Button(action: {
                        showEqualizer = true
                    }) {
                        Image(systemName: "slider.vertical.3")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.redPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Large Circular Artwork
                ZStack {
                    Circle()
                        .fill(Color.blackCard)
                        .frame(width: 260, height: 260)
                        .shadow(color: Color.redPrimary.opacity(0.3), radius: 24, x: 0, y: 12)

                    Circle()
                        .stroke(Color.redPrimary.opacity(0.8), lineWidth: 3)
                        .frame(width: 260, height: 260)

                    Image(systemName: "music.note")
                        .font(.system(size: 90))
                        .foregroundColor(.redPrimary)
                }

                Spacer()

                // Song Title & Artist
                VStack(spacing: 6) {
                    Text(viewModel.playerService.currentSong?.title ?? "No Song Selected")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.whitePrimary)
                        .lineLimit(1)
                        .padding(.horizontal, 24)

                    Text(viewModel.playerService.currentSong?.artist ?? "Select a track to play")
                        .font(.system(size: 16))
                        .foregroundColor(.whiteSecondary)
                        .lineLimit(1)
                }

                // Seekbar & Time labels
                VStack(spacing: 6) {
                    Slider(
                        value: Binding(
                            get: { isSeeking ? seekTime : viewModel.playerService.currentTime },
                            set: { newValue in
                                isSeeking = true
                                seekTime = newValue
                            }
                        ),
                        in: 0...(viewModel.playerService.duration > 0 ? viewModel.playerService.duration : 1),
                        onEditingChanged: { editing in
                            if !editing {
                                viewModel.playerService.seek(to: seekTime)
                                isSeeking = false
                            }
                        }
                    )
                    .accentColor(.redPrimary)
                    .padding(.horizontal, 24)

                    HStack {
                        Text(formatTime(isSeeking ? seekTime : viewModel.playerService.currentTime))
                            .font(.system(size: 12))
                            .foregroundColor(.whiteSecondary)

                        Spacer()

                        Text(formatTime(viewModel.playerService.duration))
                            .font(.system(size: 12))
                            .foregroundColor(.whiteSecondary)
                    }
                    .padding(.horizontal, 28)
                }

                // Controls Row: Previous, Play/Pause FAB, Next
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.previousSong()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.whitePrimary)
                    }

                    Button(action: {
                        viewModel.playerService.togglePlayPause()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.redPrimary)
                                .frame(width: 68, height: 68)
                                .shadow(color: Color.redPrimary.opacity(0.5), radius: 12, x: 0, y: 6)

                            Image(systemName: viewModel.playerService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.whitePrimary)
                        }
                    }

                    Button(action: {
                        viewModel.nextSong()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.whitePrimary)
                    }
                }
                .padding(.top, 10)

                // Secondary Controls Row: Shuffle, Repeat, Favorite
                HStack(spacing: 50) {
                    Button(action: {
                        viewModel.isShuffleEnabled.toggle()
                    }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20))
                            .foregroundColor(viewModel.isShuffleEnabled ? .redPrimary : .whiteSecondary)
                    }

                    Button(action: {
                        viewModel.repeatMode = (viewModel.repeatMode + 1) % 3
                    }) {
                        Image(systemName: viewModel.repeatMode == 2 ? "repeat.1" : "repeat")
                            .font(.system(size: 20))
                            .foregroundColor(viewModel.repeatMode != 0 ? .redPrimary : .whiteSecondary)
                    }

                    Button(action: {
                        // Favorite toggle
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.whiteSecondary)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showEqualizer) {
            EqualizerView(viewModel: viewModel)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
