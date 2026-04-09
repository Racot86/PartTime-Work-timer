//
//  TaskDetailView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var store: TimerStore

    let projectID: UUID
    let taskID: UUID

    private let statColumns = [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 10)]

    var body: some View {
        if let project = store.project(with: projectID), let task = store.task(projectID: projectID, taskID: taskID) {
            GlassEffectContainer(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    statusStrip(project: project, task: task)
                    stats(task: task)
                    recordsSection(project: project, task: task)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView()
        }
    }

    private func statusStrip(project: WorkProject, task: WorkTask) -> some View {
        DetailStatusStripView(
            items: taskStatusItems(project: project, task: task),
            note: taskStatusNote(project: project, task: task),
            noteSystemImage: taskStatusNoteSystemImage(project: project, task: task),
            noteTint: taskStatusNoteTint(project: project, task: task)
        )
    }

    private func taskStatusItems(project: WorkProject, task: WorkTask) -> [DetailStatusItem] {
        var items = [
            DetailStatusItem(
                title: task.isCompleted ? "Completed" : "Open",
                systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle",
                tint: task.isCompleted
                    ? WorkTimerGlassPalette.completionIcon
                    : WorkTimerGlassPalette.accentIcon
            )
        ]

        if store.isActiveTask(projectID: project.id, taskID: task.id) {
            items.append(
                DetailStatusItem(
                    title: "Running",
                    systemImage: "record.circle.fill",
                    tint: WorkTimerGlassPalette.runningIcon
                )
            )
        }

        return items
    }

    private func taskStatusNote(project: WorkProject, task: WorkTask) -> String? {
        if store.isActiveTask(projectID: project.id, taskID: task.id) {
            return store.activeClockText
        }

        if store.isRunning {
            return "Another task is currently running. Stop it before starting this one."
        }

        if project.isCompleted {
            return "Reopen the project before tracking more time on this task."
        }

        return nil
    }

    private func taskStatusNoteSystemImage(project: WorkProject, task: WorkTask) -> String? {
        if store.isActiveTask(projectID: project.id, taskID: task.id) {
            return "record.circle.fill"
        }

        if store.isRunning {
            return "exclamationmark.triangle"
        }

        if project.isCompleted {
            return "lock"
        }

        return nil
    }

    private func taskStatusNoteTint(project: WorkProject, task: WorkTask) -> Color {
        if store.isActiveTask(projectID: project.id, taskID: task.id) {
            return WorkTimerGlassPalette.runningIcon
        }

        return .secondary
    }

    private func stats(task: WorkTask) -> some View {
        LazyVGrid(columns: statColumns, alignment: .leading, spacing: 10) {
            DetailStatCardView(title: "Total Time", value: task.totalDurationText, detail: "All records")
            DetailStatCardView(title: "Today", value: task.todayDurationText, detail: "\(task.recordCount) total records")
            DetailStatCardView(title: "Records", value: "\(task.recordCount)", detail: "Timer start/stop sessions")
            DetailStatCardView(
                title: "Latest Entry",
                value: task.latestRecord?.durationText ?? "No records",
                detail: task.latestRecord?.dayText ?? "Track your first session"
            )
        }
    }

    private func recordsSection(project: WorkProject, task: WorkTask) -> some View {
        let orderedRecords = task.orderedRecords

        return VStack(alignment: .leading, spacing: 12) {
            Text("Time Records")
                .font(.headline)

            if orderedRecords.isEmpty {
                Text("No time records yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(orderedRecords.enumerated()), id: \.element.id) { index, record in
                            TaskRecordRowView(
                                record: record,
                                onDelete: {
                                    store.deleteRecord(projectID: project.id, taskID: task.id, recordID: record.id)
                                }
                            )

                            if index < orderedRecords.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .glassEffect(
                    .regular.tint(WorkTimerGlassPalette.raisedSurfaceTint),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
