//
//  SidebarProjectRowView.swift
//  PartTime Work timer
//

import SwiftUI

struct SidebarProjectRowView: View {
    let project: WorkProject
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: project.isCompleted ? "folder.badge.checkmark" : "folder")
                .foregroundStyle(project.isCompleted ? .secondary : Color.accentColor)
                .imageScale(.small)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline.weight(.semibold))
                    .strikethrough(project.isCompleted)
                    .lineLimit(1)

                Text("\(project.tasks.count) task\(project.tasks.count == 1 ? "" : "s") • \(project.totalDurationText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isRunning {
                Image(systemName: "timer")
                    .foregroundStyle(.red)
                    .imageScale(.small)
            } else if project.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
            }
        }
        .padding(.vertical, 2)
    }
}
