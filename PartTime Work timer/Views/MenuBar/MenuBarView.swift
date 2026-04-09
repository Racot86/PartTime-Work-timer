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
        openWindow(id: PartTime_Work_timerApp.mainWindowID)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
