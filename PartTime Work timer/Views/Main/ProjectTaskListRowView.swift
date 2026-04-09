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
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(task.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .strikethrough(task.isCompleted)
                            .lineLimit(1)

                        if task.isCompleted {
                            StatusBadgeView(title: "Completed", systemImage: "checkmark.circle.fill", tint: .secondary)
                        } else if isRunning {
                            StatusBadgeView(title: "Running", systemImage: "record.circle.fill", tint: .red)
                        }
                    }

                    Text("\(task.recordCount) record\(task.recordCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(task.totalDurationText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}
