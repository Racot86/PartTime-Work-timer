//
//  TaskRecordRowView.swift
//  PartTime Work timer
//

import SwiftUI

struct TaskRecordRowView: View {
    let record: TimeRecord
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Label(record.dayText, systemImage: "calendar")
                    .font(.subheadline.weight(.medium))

                Label(record.timeRangeText, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Label {
                Text(record.durationText)
                    .monospacedDigit()
            } icon: {
                Image(systemName: "timer")
            }
            .font(.subheadline.weight(.semibold))

            Button(role: .destructive, action: onDelete) {
                Label("Delete Record", systemImage: "trash")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
            .help("Delete Record")
        }
        .padding(.vertical, 8)
    }
}
