import SwiftUI

struct MiniPlayerBar: View {
    @ObservedObject var viewModel: MusicViewModel
    @Binding var showFullPlayer: Bool

    var body: some View {
        if let currentSong = viewModel.playerService.currentSong {
            VStack(spacing: 0) {
                // Red Progress Strip
                GeometryReader { geo in
                    let duration = viewModel.playerService.duration > 0 ? viewModel.playerService.duration : 1
                    let ratio = viewModel.playerService.currentTime / duration
                    Rectangle()
                        .fill(Color.redPrimary)
                        .frame(width: geo.size.width * CGFloat(ratio), height: 3)
                }
                .frame(height: 3)
                .background(Color.blackElevated)

                HStack(spacing: 12) {
                    // Circular Album Art
                    ZStack {
                        Circle()
                            .fill(Color.redDark)
                            .frame(width: 44, height: 44)
                        Image(systemName: "music.note")
                            .foregroundColor(.whitePrimary)
                            .font(.system(size: 18))
                    }

                    // Song Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentSong.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.whitePrimary)
                            .lineLimit(1)

                        Text(currentSong.artist)
                            .font(.system(size: 12))
                            .foregroundColor(.whiteSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Play/Pause Button
                    Button(action: {
                        viewModel.playerService.togglePlayPause()
                    }) {
                        Image(systemName: viewModel.playerService.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.redPrimary)
                            .frame(width: 36, height: 36)
                    }

                    // Skip Next
                    Button(action: {
                        viewModel.nextSong()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.whitePrimary)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blackCard)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showFullPlayer = true
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.8), radius: 8, x: 0, y: -4)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
