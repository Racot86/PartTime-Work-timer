//
//  SidebarTaskRowView.swift
//  PartTime Work timer
//

import SwiftUI

struct SidebarTaskRowView: View {
    let task: WorkTask
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 8) {
            TaskStatusIconView(task: task, isRunning: isRunning)

            Text(task.name)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            Text(task.totalDurationText)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 1)
    }
}
