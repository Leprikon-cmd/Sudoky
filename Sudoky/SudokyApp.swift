import SwiftUI

@main
struct SudokyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView() // ← теперь вся логика в RootView
        }
    }
}
