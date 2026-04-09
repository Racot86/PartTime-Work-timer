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
                Text(record.dayText)
                    .font(.subheadline.weight(.semibold))

                Text(record.timeRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(record.durationText)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()

            Button(role: .destructive, action: onDelete) {
                Label("Delete Record", systemImage: "trash")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
            .help("Delete Record")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
        )
    }
}
