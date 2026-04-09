//
//  MenuBarView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var store: TimerStore

    var body: some View {
        if store.isRunning {
            Button("Stop Timer") {
                store.stopTimer()
            }
        }

        if store.isRunning {
            Divider()
        }

        Button("Show Main Window") {
            openTrackerWindow()
        }

        Divider()

        Button("Quit App", role: .destructive) {
            NSApplication.shared.terminate(nil)
        }
    }

    private func openTrackerWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            openWindow(id: PartTime_Work_timerApp.mainWindowID)

            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                DispatchQueue.main.async {
                    appDelegate.showMainWindow()
                }
            }
        }
    }
}
