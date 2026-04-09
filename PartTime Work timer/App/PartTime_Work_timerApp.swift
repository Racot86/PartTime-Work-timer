//
//  PartTime_Work_timerApp.swift
//  PartTime Work timer
//
//  Created by Dmytro Mayevsky on 09.04.2026.
//

import SwiftData
import SwiftUI

@main
struct PartTime_Work_timerApp: App {
    static let mainWindowID = "main-window"

    private static let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for: WorkProject.self,
                WorkTask.self,
                TimeRecord.self,
                ActiveTimer.self
            )
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store: TimerStore

    init() {
        let store = TimerStore(modelContext: Self.sharedModelContainer.mainContext)
        _store = StateObject(wrappedValue: store)
    }

    var body: some Scene {
        Window("Part-Time Work Timer", id: Self.mainWindowID) {
            ContentView()
                .environmentObject(store)
                .modelContainer(Self.sharedModelContainer)
                .background(
                    WindowAccessor { window in
                        appDelegate.configureMainWindow(window)
                    }
                )
        }
        .defaultSize(width: 1040, height: 680)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
                .modelContainer(Self.sharedModelContainer)
        } label: {
            MenuBarLabelView(store: store)
        }
        .menuBarExtraStyle(.menu)
    }
}
