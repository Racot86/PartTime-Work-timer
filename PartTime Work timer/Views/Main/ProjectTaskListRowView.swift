//
//  ProjectTaskListRowView.swift
//  PartTime Work timer
//

import SwiftUI

struct ProjectTaskListRowView: View {
    let task: WorkTask
    let isRunning: Bool
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    TaskStatusIconView(task: task, isRunning: isRunning)

                    Text(task.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(task.totalDurationText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }

                HStack(spacing: 8) {
                    Label(
                        "\(task.recordCount) record\(task.recordCount == 1 ? "" : "s")",
                        systemImage: "clock"
                    )

                    if let latestRecord = task.latestRecord {
                        Label(latestRecord.dayText, systemImage: "calendar")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
