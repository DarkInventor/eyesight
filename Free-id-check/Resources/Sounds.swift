import Foundation
import AppKit
import AVFoundation

enum Sound: String, CaseIterable {
    case breakStart = "break-start"
    case breakEnd = "break-end"
    case notification = "notification"
    
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: fileExtension)
    }
    
    var fileExtension: String {
        switch self {
        case .notification:
            return "aiff"
        default:
            return "wav"
        }
    }
}

class SoundManager {
    static let shared = SoundManager()
    
    private var sounds: [Sound: AVAudioPlayer] = [:]
    private var isEnabled: Bool = true
    
    private init() {
        loadSounds()
    }
    
    private func loadSounds() {
        Sound.allCases.forEach { sound in
            if let url = sound.url {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    sounds[sound] = player
                } catch {
                    print("Failed to load sound \(sound.rawValue): \(error)")
                }
            }
        }
    }
    
    func play(_ sound: Sound) {
        guard isEnabled else { return }
        
        if let player = sounds[sound] {
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        } else {
            // Fallback to system sound
            NSSound.beep()
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            sounds.values.forEach { $0.stop() }
        }
    }
} 