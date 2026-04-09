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

            Text(project.name)
                .font(.subheadline.weight(.medium))
                .strikethrough(project.isCompleted)
                .lineLimit(1)

            Spacer()

            Text(project.totalDurationText)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            if isRunning {
                Image(systemName: "record.circle.fill")
                .foregroundStyle(.red)
                .imageScale(.small)
            } else if project.isCompleted {
                Image(systemName: "checkmark")
                .foregroundStyle(.secondary)
                .imageScale(.small)
            }
        }
        .padding(.vertical, 1)
    }
}
