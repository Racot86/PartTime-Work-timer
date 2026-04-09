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
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .secondary : .secondary)
                .imageScale(.small)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)

                Text("\(task.recordCount) record\(task.recordCount == 1 ? "" : "s") • \(task.totalDurationText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isRunning {
                Image(systemName: "record.circle.fill")
                    .foregroundStyle(.red)
                    .imageScale(.small)
            }
        }
        .padding(.vertical, 1)
    }
}
