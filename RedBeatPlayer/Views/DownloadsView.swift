import SwiftUI

struct DownloadsView: View {
    @StateObject private var downloadViewModel = DownloadViewModel()
    @ObservedObject var musicViewModel: MusicViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.blackBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // URL Input Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("DOWNLOAD FROM URL")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.redPrimary)

                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.redPrimary)

                                TextField("Enter direct audio URL (e.g. .mp3, .m4a)", text: $downloadViewModel.urlInput)
                                    .foregroundColor(.whitePrimary)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding(12)
                            .background(Color.blackSurface)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blackDivider, lineWidth: 1)
                            )

                            Button(action: {
                                downloadViewModel.startDownload(urlString: downloadViewModel.urlInput) {
                                    musicViewModel.loadLocalSongs()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("Download to Offline Library")
                                }
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.whitePrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.redPrimary)
                                .cornerRadius(24)
                            }
                        }
                        .padding(16)
                        .background(Color.blackCard)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        // Active / Completed Downloads
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACTIVE & RECENT DOWNLOADS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(.whiteSecondary)
                                .padding(.horizontal, 16)

                            if downloadViewModel.downloads.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.down.doc")
                                        .font(.system(size: 36))
                                        .foregroundColor(.whiteDisabled)
                                    Text("No downloads yet")
                                        .font(.system(size: 14))
                                        .foregroundColor(.whiteSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(downloadViewModel.downloads) { item in
                                    DownloadRowView(item: item)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Music Downloader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Downloads")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.whitePrimary)
                }
            }
            .alert("Download Error", isPresented: $downloadViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(downloadViewModel.alertMessage ?? "An error occurred")
            }
        }
    }
}

struct DownloadRowView: View {
    @ObservedObject var item: DownloadItem

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? Color.redPrimary : Color.blackElevated)
                        .frame(width: 40, height: 40)
                    Image(systemName: item.isCompleted ? "checkmark" : "arrow.down")
                        .foregroundColor(.whitePrimary)
                        .font(.system(size: 16, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.whitePrimary)
                        .lineLimit(1)

                    Text(item.status)
                        .font(.system(size: 12))
                        .foregroundColor(item.isCompleted ? .redPrimary : .whiteSecondary)
                }

                Spacer()

                Text("\(Int(item.progress * 100))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.redPrimary)
            }

            ProgressView(value: item.progress)
                .accentColor(.redPrimary)
        }
        .padding(12)
        .background(Color.blackCard)
        .cornerRadius(12)
    }
}
