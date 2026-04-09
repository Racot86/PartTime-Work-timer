//
//  TaskStatusIconView.swift
//  PartTime Work timer
//

import SwiftUI

struct TaskStatusIconView: View {
    let task: WorkTask
    let isRunning: Bool

    var body: some View {
        Image(systemName: symbolName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(symbolColor)
            .frame(width: 14)
            .accessibilityHidden(true)
    }

    private var symbolName: String {
        if isRunning {
            return "record.circle.fill"
        }

        if task.isCompleted {
            return "checkmark.circle.fill"
        }

        return task.recordCount > 0 ? "list.bullet.circle.fill" : "list.bullet.circle"
    }

    private var symbolColor: Color {
        if isRunning {
            return .red
        }

        if task.isCompleted {
            return .green
        }

        return task.recordCount > 0 ? .accentColor : .secondary
    }
}
