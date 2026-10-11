//
//  MusicManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 30.05.2025.
//

import AVFoundation

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    private var player: AVAudioPlayer?
    private var playerURL: URL?
    private var audioSessionIsActive = false

    /// Проверка: играет ли музыка сейчас
    var isMusicPlaying: Bool {
        player?.isPlaying ?? false
    }

    /// Запускает музыку, если она ещё не играет
    @discardableResult
    func playBackgroundMusic(_ filename: String, fileExtension: String = "m4a", loop: Bool = true) -> Bool {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("❌ Музыка \(filename).\(fileExtension) не найдена")
            return false
        }

        if player?.isPlaying == true {
            return true
        }

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true)
            audioSessionIsActive = true

            if playerURL != url {
                player = try AVAudioPlayer(contentsOf: url)
                playerURL = url
            }

            guard let player else {
                deactivate(audioSession)
                return false
            }

            player.currentTime = 0
            player.numberOfLoops = loop ? -1 : 0
            player.volume = 0.5
            guard player.play() else {
                print("❌ Не удалось запустить музыку \(filename).\(fileExtension)")
                player.stop()
                deactivate(audioSession)
                return false
            }

            return true
        } catch {
            print("❌ Ошибка воспроизведения: \(error.localizedDescription)")
            player?.stop()
            if audioSessionIsActive {
                deactivate(audioSession)
            }
            return false
        }
    }

    /// Останавливает музыку
    func stopMusic() {
        player?.stop()
        if audioSessionIsActive {
            deactivate(AVAudioSession.sharedInstance())
        }
    }

    private func deactivate(_ audioSession: AVAudioSession) {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            audioSessionIsActive = false
        } catch {
            print("❌ Ошибка отключения аудиосессии: \(error.localizedDescription)")
        }
    }
}
