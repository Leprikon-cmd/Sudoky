//
//  MusicManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 30.05.2025.
//

import AVFoundation
import Combine
import Foundation

class MusicManager: ObservableObject {
    static let shared = MusicManager()

    private let operationExecutor = MusicOperationExecutor()
    private var player: AVAudioPlayer?
    private var playerURL: URL?
    private var audioSessionIsActive = false

    /// Проверка: играет ли музыка сейчас
    @Published private(set) var isMusicPlaying = false

    /// Меняет состояние фоновой музыки вне главного потока.
    func setMusicEnabled(
        _ enabled: Bool,
        filename: String = "Aurnis_Luthael",
        fileExtension: String = "m4a",
        loop: Bool = true,
        completion: @escaping (Bool) -> Void
    ) {
        operationExecutor.perform({
            return enabled
                ? self.startMusic(filename, fileExtension: fileExtension, loop: loop)
                : self.stopMusicOnAudioQueue()
        }) { [weak self] succeeded in
            guard let self else { return }
            self.isMusicPlaying = succeeded && enabled
            completion(succeeded)
        }
    }

    private func startMusic(_ filename: String, fileExtension: String, loop: Bool) -> Bool {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("❌ Музыка \(filename).\(fileExtension) не найдена")
            return false
        }
        if player?.isPlaying == true { return true }

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
                _ = deactivate(audioSession)
                return false
            }

            player.currentTime = 0
            player.numberOfLoops = loop ? -1 : 0
            player.volume = 0.5
            guard player.prepareToPlay() else {
                print("❌ Не удалось подготовить музыку \(filename).\(fileExtension)")
                player.stop()
                _ = deactivate(audioSession)
                return false
            }
            guard player.play() else {
                print("❌ Не удалось запустить музыку \(filename).\(fileExtension)")
                player.stop()
                _ = deactivate(audioSession)
                return false
            }

            return true
        } catch {
            print("❌ Ошибка воспроизведения: \(error.localizedDescription)")
            player?.stop()
            if audioSessionIsActive {
                _ = deactivate(audioSession)
            }
            return false
        }
    }

    private func stopMusicOnAudioQueue() -> Bool {
        player?.stop()
        if audioSessionIsActive {
            _ = deactivate(AVAudioSession.sharedInstance())
        }
        return player?.isPlaying != true
    }

    @discardableResult
    private func deactivate(_ audioSession: AVAudioSession) -> Bool {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            audioSessionIsActive = false
            return true
        } catch {
            print("❌ Ошибка отключения аудиосессии: \(error.localizedDescription)")
            return false
        }
    }
}
