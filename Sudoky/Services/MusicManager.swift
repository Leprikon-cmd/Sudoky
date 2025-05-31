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

    /// Проверка: играет ли музыка сейчас
    var isMusicPlaying: Bool {
        player?.isPlaying ?? false
    }

    /// Запускает музыку, если она ещё не играет
    func playBackgroundMusic(_ filename: String, fileExtension: String = "m4a", loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("❌ Музыка \(filename).\(fileExtension) не найдена")
            return
        }

        do {
            if player?.isPlaying == true {
                print("🎵 Музыка уже играет — повторный запуск не требуется")
                return
            }

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = loop ? -1 : 0
            player?.volume = 0.5
            player?.play()
            print("🎵 Играет: \(filename)")
        } catch {
            print("❌ Ошибка воспроизведения: \(error.localizedDescription)")
        }
    }

    /// Останавливает музыку
    func stopMusic() {
        player?.stop()
        print("⏹ Музыка остановлена")
    }
}
