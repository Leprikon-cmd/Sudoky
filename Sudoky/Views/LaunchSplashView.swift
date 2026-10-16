import SwiftUI

struct StartupView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsMainView = false
    @State private var isTransitioning = false
    @State private var splashOpacity = 1.0
    @State private var hasScheduledTransition = false

    var body: some View {
        ZStack {
            if isTransitioning || showsMainView {
                RootView()
                    .zIndex(0)
            }
            if !showsMainView {
                LaunchSplashView()
                    .opacity(splashOpacity)
                    .zIndex(1)
            }
        }
        .allowsHitTesting(showsMainView)
        .environment(\.startupTransitionComplete, showsMainView)
        .task {
            guard !hasScheduledTransition else { return }
            hasScheduledTransition = true

            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                hasScheduledTransition = false
                return
            }

            guard !Task.isCancelled else { return }
            if reduceMotion {
                showsMainView = true
            } else {
                isTransitioning = true
                withAnimation(.easeInOut(duration: 0.55)) {
                    splashOpacity = 0
                }
                do {
                    try await Task.sleep(for: .seconds(0.55))
                } catch {
                    isTransitioning = false
                    splashOpacity = 1
                    hasScheduledTransition = false
                    return
                }
                guard !Task.isCancelled else { return }
                showsMainView = true
                isTransitioning = false
            }
        }
    }
}

struct StartupTransitionCompleteKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var startupTransitionComplete: Bool {
        get { self[StartupTransitionCompleteKey.self] }
        set { self[StartupTransitionCompleteKey.self] = newValue }
    }
}

private struct LaunchSplashView: View {
    var body: some View {
        GeometryReader { geometry in
            if StartupGeometry.hasUsableSize(geometry.size) {
                Image("Launch_Garden")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } else {
                Color.clear
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
