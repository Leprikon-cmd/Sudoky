import SwiftUI
import UIKit

struct BookletPageCurlView: UIViewControllerRepresentable {
    let pages: [BookletPage]
    let layout: BookletLayout
    @Binding var currentPageIndex: Int
    let reduceMotion: Bool
    let pageContent: (Int) -> AnyView

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let transitionStyle: UIPageViewController.TransitionStyle = reduceMotion ? .scroll : .pageCurl
        let controller = UIPageViewController(
            transitionStyle: transitionStyle,
            navigationOrientation: .horizontal,
            options: nil
        )
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        controller.isDoubleSided = false
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator

        if !pages.isEmpty {
            let index = min(max(currentPageIndex, 0), pages.count - 1)
            controller.setViewControllers(
                [context.coordinator.hostedController(at: index)],
                direction: .forward,
                animated: false
            )
            context.coordinator.displayedIndex = index
        }
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        context.coordinator.update(parent: self, controller: controller)
    }

    @MainActor
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        private var parent: BookletPageCurlView
        private var pendingParent: BookletPageCurlView?
        private var hostedControllers: [Int: UIHostingController<AnyView>] = [:]
        private var indicesByController: [ObjectIdentifier: Int] = [:]
        private var isTransitioning = false
        var displayedIndex: Int?

        init(parent: BookletPageCurlView) {
            self.parent = parent
        }

        func update(parent newParent: BookletPageCurlView, controller: UIPageViewController) {
            guard !isTransitioning else {
                // Apply the latest localized/layout state only after UIKit finishes the active curl.
                pendingParent = newParent
                return
            }
            apply(parent: newParent, controller: controller)
        }

        private func apply(parent newParent: BookletPageCurlView, controller: UIPageViewController) {
            let oldIDs = parent.pages.map(\.id)
            let newIDs = newParent.pages.map(\.id)
            parent = newParent

            if oldIDs != newIDs {
                hostedControllers.removeAll()
                indicesByController.removeAll()
                displayedIndex = nil
            } else {
                for (index, hosted) in hostedControllers where index < parent.pages.count {
                    hosted.rootView = parent.pageContent(index)
                }
                hostedControllers = hostedControllers.filter { $0.key < parent.pages.count }
                indicesByController = Dictionary(
                    uniqueKeysWithValues: hostedControllers.map { (ObjectIdentifier($0.value), $0.key) }
                )
            }

            guard !parent.pages.isEmpty else {
                controller.setViewControllers(nil, direction: .forward, animated: false)
                displayedIndex = nil
                return
            }

            let targetIndex = min(max(parent.currentPageIndex, 0), parent.pages.count - 1)
            if displayedIndex != targetIndex {
                controller.setViewControllers(
                    [hostedController(at: targetIndex)],
                    direction: targetIndex >= (displayedIndex ?? 0) ? .forward : .reverse,
                    animated: false
                )
                displayedIndex = targetIndex
            }
        }

        func hostedController(at index: Int) -> UIHostingController<AnyView> {
            if let existing = hostedControllers[index] {
                existing.rootView = parent.pageContent(index)
                return existing
            }

            let hosted = UIHostingController(rootView: parent.pageContent(index))
            hosted.view.backgroundColor = .clear
            hosted.view.isOpaque = false
            hosted.view.accessibilityIdentifier = "garden-help-page-\(index + 1)"
            hostedControllers[index] = hosted
            indicesByController[ObjectIdentifier(hosted)] = index
            return hosted
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = indicesByController[ObjectIdentifier(viewController)], index > 0 else { return nil }
            return hostedController(at: index - 1)
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard
                let index = indicesByController[ObjectIdentifier(viewController)],
                index + 1 < parent.pages.count
            else { return nil }
            return hostedController(at: index + 1)
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            spineLocationFor orientation: UIInterfaceOrientation
        ) -> UIPageViewController.SpineLocation {
            pageViewController.isDoubleSided = false
            return .min
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            isTransitioning = true
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            isTransitioning = false
            if let pendingParent {
                // A reset to page one must not be overwritten by the page that just finished curling.
                self.pendingParent = nil
                apply(parent: pendingParent, controller: pageViewController)
                return
            }

            if completed,
               let visibleController = pageViewController.viewControllers?.first,
               let index = indicesByController[ObjectIdentifier(visibleController)] {
                displayedIndex = index
                parent.currentPageIndex = index
            }

            if let visibleController = pageViewController.viewControllers?.first,
               let index = indicesByController[ObjectIdentifier(visibleController)] {
                displayedIndex = index
            }
        }
    }
}
