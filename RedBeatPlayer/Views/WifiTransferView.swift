import SwiftUI

struct WifiTransferView: View {
    @State private var isServerActive = false
    @State private var localIP = "192.168.1.105"

    var body: some View {
        NavigationView {
            ZStack {
                Color.blackBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Wi-Fi Icon
                        ZStack {
                            Circle()
                                .fill(Color.redPrimary)
                                .frame(width: 84, height: 84)
                                .shadow(color: Color.redPrimary.opacity(0.4), radius: 16, x: 0, y: 8)

                            Image(systemName: "wifi")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.whitePrimary)
                        }
                        .padding(.top, 16)

                        // Status & IP
                        VStack(spacing: 6) {
                            Text(isServerActive ? "Server Running" : "Server Stopped")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isServerActive ? .redPrimary : .whiteSecondary)

                            Text(isServerActive ? "http://\(localIP):8080" : "http://0.0.0.0:8080")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.whitePrimary)
                        }

                        // Instructions Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How Wireless Transfer Works:")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.redPrimary)

                            Text("1. Connect your iPhone and computer to the same Wi-Fi.\n2. Tap 'Start Transfer Server' below.\n3. Open the web link above in your browser.\n4. Drag & drop MP3 music files directly into your iPhone library!")
                                .font(.system(size: 13))
                                .lineSpacing(4)
                                .foregroundColor(.whiteSecondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blackCard)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blackDivider, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // Server Toggle Button
                        Button(action: {
                            isServerActive.toggle()
                        }) {
                            Text(isServerActive ? "Stop Transfer Server" : "Start Transfer Server")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.whitePrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isServerActive ? Color.redDark : Color.redPrimary)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 20)

                        // Developer & Instagram Link
                        Link(destination: DeveloperConstants.instagramURL) {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.redPrimary)

                                Text("Rebuilt & Designed by")
                                    .font(.system(size: 13))
                                    .foregroundColor(.whiteSecondary)

                                Text(DeveloperConstants.instagramHandle)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.redPrimary)

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.redPrimary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.blackSurface)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.redPrimary.opacity(0.8), lineWidth: 1)
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Wi-Fi Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wi-Fi Transfer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.whitePrimary)
                }
            }
        }
    }
}
