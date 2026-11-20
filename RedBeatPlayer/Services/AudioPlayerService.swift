import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerService: NSObject, ObservableObject {
    static let shared = AudioPlayerService()

    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var equalizerNode = AVAudioUnitEQ(numberOfBands: 5)

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var audioFile: AVAudioFile?
    private var timer: AnyCancellable?
    private var currentFrame: AVAudioFramePosition = 0
    private var audioLengthFrames: AVAudioFramePosition = 0
    private var audioSampleRate: Double = 44100

    // Equalizer frequencies (60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz)
    let bandFrequencies: [Float] = [60, 230, 910, 3600, 14000]

    override init() {
        super.init()
        setupAudioSession()
        setupEngine()
        setupRemoteCommands()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
        }
    }

    private func setupEngine() {
        audioEngine.attach(playerNode)
        audioEngine.attach(equalizerNode)

        // Configure 5 parametric EQ bands
        for (i, freq) in bandFrequencies.enumerated() {
            let band = equalizerNode.bands[i]
            band.frequency = freq
            band.bandwidth = 1.0
            band.filterType = .parametric
            band.gain = 0.0
            band.bypass = false
        }

        audioEngine.connect(playerNode, to: equalizerNode, format: nil)
        audioEngine.connect(equalizerNode, to: audioEngine.mainMixerNode, format: nil)

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
        }
    }

    func setBandGain(index: Int, gain: Float) {
        guard index >= 0 && index < equalizerNode.bands.count else { return }
        equalizerNode.bands[index].gain = gain
    }

    func playSong(_ song: Song) {
        guard let url = song.fileURL else { return }

        stop()
        currentSong = song

        do {
            let file = try AVAudioFile(forReading: url)
            self.audioFile = file
            self.audioLengthFrames = file.length
            self.audioSampleRate = file.processingFormat.sampleRate
            self.duration = Double(file.length) / audioSampleRate

            playerNode.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.isPlaying = false
                }
            }

            if !audioEngine.isRunning {
                try audioEngine.start()
            }

            playerNode.play()
            isPlaying = true
            startProgressTimer()
            updateNowPlayingInfo()
        } catch {
            print("Failed to play audio file: \(error)")
        }
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func pause() {
        playerNode.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func resume() {
        playerNode.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func stop() {
        playerNode.stop()
        isPlaying = false
        timer?.cancel()
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        guard let file = audioFile else { return }
        playerNode.stop()

        let targetFrame = AVAudioFramePosition(time * audioSampleRate)
        let framesToPlay = AVAudioFrameCount(audioLengthFrames - targetFrame)

        if framesToPlay > 0 {
            playerNode.scheduleSegment(file, startingFrame: targetFrame, frameCount: framesToPlay, at: nil, completionHandler: nil)
            playerNode.play()
            isPlaying = true
            currentTime = time
            updateNowPlayingInfo()
        }
    }

    private func startProgressTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                if let nodeTime = self.playerNode.lastRenderTime,
                   let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) {
                    let seconds = Double(playerTime.sampleTime) / playerTime.sampleRate
                    self.currentTime = min(seconds, self.duration)
                }
            }
    }

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong else { return }
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = song.album
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
