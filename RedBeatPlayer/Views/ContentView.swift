import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MusicViewModel()
    @State private var selectedTab = 0
    @State private var showFullPlayer = false

    init() {
        // Red & Black Dark TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: 0x141414)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(white: 0.7, alpha: 1.0)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.7, alpha: 1.0)]

        itemAppearance.selected.iconColor = UIColor(hex: 0xE53935)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(hex: 0xE53935)]

        appearance.stackedLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView(viewModel: viewModel, showFullPlayer: $showFullPlayer)
                    .tabItem {
                        Label("Library", systemImage: "music.note.house.fill")
                    }
                    .tag(0)

                NowPlayingView(viewModel: viewModel)
                    .tabItem {
                        Label("Player", systemImage: "play.circle.fill")
                    }
                    .tag(1)

                PlaylistsView(viewModel: viewModel)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    .tag(2)

                DownloadsView(musicViewModel: viewModel)
                    .tabItem {
                        Label("Downloads", systemImage: "arrow.down.circle.fill")
                    }
                    .tag(3)

                WifiTransferView()
                    .tabItem {
                        Label("Wi-Fi", systemImage: "wifi")
                    }
                    .tag(4)
            }
            .accentColor(.redPrimary)

            // Floating Mini Player (visible on other tabs when music is playing)
            if selectedTab != 1 {
                MiniPlayerBar(viewModel: viewModel, showFullPlayer: $showFullPlayer)
                    .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            NowPlayingView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            green: CGFloat((hex >> 08) & 0xff) / 255.0,
            blue: CGFloat((hex >> 00) & 0xff) / 255.0,
            alpha: alpha
        )
    }
}
