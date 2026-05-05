import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private var backgroundMusic: AVAudioPlayer?
    private var dogPlayer: AVAudioPlayer?
    private var jumpPlayer: AVAudioPlayer?
    private var loseLifePlayer: AVAudioPlayer?
    private var gameOverPlayer: AVAudioPlayer?

    private var backgroundedWhilePlaying = false

    private init() {
        jumpPlayer     = makePlayer("salto",    volume: 0.6)
        loseLifePlayer = makePlayer("loselife", volume: 0.8)
    }

    // MARK: - Background music

    func startBackgroundMusic() {
        guard let player = makePlayer("musicloop", ext: "mp3", volume: 0.5) else { return }
        player.numberOfLoops = -1
        player.play()
        backgroundMusic = player
    }

    func stopBackgroundMusic() {
        backgroundMusic?.stop()
        backgroundMusic = nil
    }

    // MARK: - One-shot sounds

    func playGameOverSound() {
        gameOverPlayer = makePlayer("gameover", ext: "mp3", volume: 0.7)
        gameOverPlayer?.play()
    }

    func playJumpSound() {
        jumpPlayer?.currentTime = 0
        jumpPlayer?.play()
    }

    func playLoseLifeSound() {
        loseLifePlayer?.currentTime = 0
        loseLifePlayer?.play()
    }

    func playDogAppearedSound() {
        guard dogPlayer?.isPlaying != true else { return }
        let name = Bool.random() ? "aparicionperro" : "aparicionperroperro"
        dogPlayer = makePlayer(name, volume: 0.85)
        dogPlayer?.play()
    }

    // MARK: - Event dispatcher

    func process(_ events: [SoundEvent]) {
        for event in events {
            switch event {
            case .jump:
                playJumpSound()
#if os(iOS) || os(visionOS)
                HapticManager.shared.jumpFeedback()
#endif
            case .loseLife:
                playLoseLifeSound()
#if os(iOS) || os(visionOS)
                HapticManager.shared.loseLifeFeedback()
#endif
            case .dogAppeared:
                playDogAppearedSound()
            case .gameOver:
                playGameOverSound()
#if os(iOS) || os(visionOS)
                HapticManager.shared.gameOverFeedback()
#endif
            case .powerUp:
#if os(iOS) || os(visionOS)
                HapticManager.shared.powerUpFeedback()
#endif
            }
        }
    }

    // MARK: - App lifecycle

    func pauseForBackground() {
        guard backgroundMusic?.isPlaying == true else { return }
        backgroundMusic?.pause()
        backgroundedWhilePlaying = true
    }

    func resumeFromBackground() {
        guard backgroundedWhilePlaying else { return }
        backgroundMusic?.play()
        backgroundedWhilePlaying = false
    }

    // MARK: - Lifecycle

    func release() {
        backgroundMusic?.stop();  backgroundMusic  = nil
        dogPlayer?.stop();        dogPlayer        = nil
        jumpPlayer?.stop();       jumpPlayer       = nil
        loseLifePlayer?.stop();   loseLifePlayer   = nil
        gameOverPlayer?.stop();   gameOverPlayer   = nil
    }

    // MARK: - Private

    private func makePlayer(_ name: String, ext: String = "mp3", volume: Float = 1.0) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = volume
        player?.prepareToPlay()
        return player
    }
}
