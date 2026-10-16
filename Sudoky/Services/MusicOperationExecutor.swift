import Foundation

final class MusicOperationExecutor {
    private let queue = DispatchQueue(label: "com.sudoky.music-manager.audio")

    func perform<Result>(
        _ operation: @escaping () -> Result,
        completion: @escaping (Result) -> Void
    ) {
        queue.async {
            let result = operation()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
