import Foundation
import Combine

class DownloadViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloads: [DownloadItem] = []
    @Published var urlInput: String = ""
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false

    private var urlSession: URLSession!
    private var tasks: [URLSessionDownloadTask: DownloadItem] = [:]

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }

    func startDownload(urlString: String, onComplete: @escaping () -> Void) {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            alertMessage = "Please enter a valid HTTP or HTTPS audio URL"
            showAlert = true
            return
        }

        let filename = url.lastPathComponent.isEmpty ? "Track_\(Int(Date().timeIntervalSince1970)).mp3" : url.lastPathComponent
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicDir = docs.appendingPathComponent("Music", isDirectory: true)

        try? fileManager.createDirectory(at: musicDir, withIntermediateDirectories: true)
        let destination = musicDir.appendingPathComponent(filename)

        let item = DownloadItem(
            id: UUID(),
            title: filename,
            url: urlString,
            progress: 0.05,
            status: "Downloading...",
            isCompleted: false,
            destinationURL: destination
        )

        downloads.insert(item, at: 0)
        let task = urlSession.downloadTask(with: url)
        tasks[task] = item
        task.resume()

        urlInput = ""
    }

    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let item = tasks[downloadTask] else { return }

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: item.destinationURL)
        do {
            try fileManager.moveItem(at: location, to: item.destinationURL)
            DispatchQueue.main.async {
                item.progress = 1.0
                item.status = "Saved to Library"
                item.isCompleted = true
            }
        } catch {
            DispatchQueue.main.async {
                item.status = "Failed: \(error.localizedDescription)"
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let item = tasks[downloadTask], totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            item.progress = progress
            item.status = String(format: "%.1f MB / %.1f MB", Double(totalBytesWritten)/(1024*1024), Double(totalBytesExpectedToWrite)/(1024*1024))
        }
    }
}
