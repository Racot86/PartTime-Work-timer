//
//  AppDelegate.swift
//  PartTime Work timer
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private static let requestShowMainWindowNotification = Notification.Name(
        "me.PartTime-Work-timer.request-show-main-window"
    )

    private var mainWindow: NSWindow?
    private let distributedNotificationCenter = DistributedNotificationCenter.default()

    func applicationWillFinishLaunching(_ notification: Notification) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }

        let otherRunningInstance = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .first { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }

        guard otherRunningInstance != nil else {
            return
        }

        distributedNotificationCenter.postNotificationName(
            Self.requestShowMainWindowNotification,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
        NSApplication.shared.terminate(nil)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        distributedNotificationCenter.addObserver(
            self,
            selector: #selector(handleRequestShowMainWindowNotification),
            name: Self.requestShowMainWindowNotification,
            object: nil
        )
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard !flag else { return false }
        showMainWindow()
        return true
    }

    func configureMainWindow(_ window: NSWindow) {
        window.identifier = NSUserInterfaceItemIdentifier(PartTime_Work_timerApp.mainWindowID)
        window.isReleasedWhenClosed = false

        guard mainWindow !== window else { return }
        mainWindow = window
        window.delegate = self
        setRegularActivationPolicy()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard sender === mainWindow else { return true }
        hideMainWindow()
        return false
    }

    func showMainWindow() {
        DispatchQueue.main.async {
            self.setRegularActivationPolicy()
            NSApplication.shared.unhide(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)

            if let mainWindow = self.resolvedMainWindow() {
                if mainWindow.isMiniaturized {
                    mainWindow.deminiaturize(nil)
                }

                if !mainWindow.isVisible {
                    mainWindow.setIsVisible(true)
                }

                mainWindow.orderFrontRegardless()
                mainWindow.makeKeyAndOrderFront(nil)
            }
        }
    }

    private func hideMainWindow() {
        mainWindow?.orderOut(nil)

        DispatchQueue.main.async {
            self.setAccessoryActivationPolicy()
        }
    }

    private func setAccessoryActivationPolicy() {
        guard NSApplication.shared.activationPolicy() != .accessory else { return }
        _ = NSApplication.shared.setActivationPolicy(.accessory)
    }

    private func setRegularActivationPolicy() {
        guard NSApplication.shared.activationPolicy() != .regular else { return }
        _ = NSApplication.shared.setActivationPolicy(.regular)
    }

    @objc
    private func handleRequestShowMainWindowNotification() {
        showMainWindow()
    }

    private func resolvedMainWindow() -> NSWindow? {
        if let mainWindow {
            return mainWindow
        }

        let resolvedWindow = NSApplication.shared.windows.first {
            $0.identifier?.rawValue == PartTime_Work_timerApp.mainWindowID
        }
        mainWindow = resolvedWindow
        return resolvedWindow
    }
}
