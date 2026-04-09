//
//  MenuBarLabelView.swift
//  PartTime Work timer
//

import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var store: TimerStore

    var body: some View {
        Group {
            if store.isRunning {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                    Text(store.activeClockText)
                        .monospacedDigit()
                }
            } else {
                Image(systemName: "clock")
            }
        }
    }
}
