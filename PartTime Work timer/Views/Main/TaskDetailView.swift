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
    let onShowProject: () -> Void

    private let statColumns = [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)]

    var body: some View {
        if let project = store.project(with: projectID), let task = store.task(projectID: projectID, taskID: taskID) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header(project: project, task: task)
                    stats(task: task)
                    recordsSection(project: project, task: task)
                }
                .padding(18)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView(onCreateProject: {})
        }
    }

    private func header(project: WorkProject, task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: onShowProject) {
                        Label(project.name, systemImage: "folder")
                    }
                    .buttonStyle(.link)
                    .controlSize(.small)

                    Text(task.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    HStack(spacing: 8) {
                        StatusBadgeView(
                            title: task.isCompleted ? "Completed" : "Open",
                            systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle",
                            tint: task.isCompleted ? .secondary : .accentColor
                        )

                        if store.isActiveTask(projectID: project.id, taskID: task.id) {
                            StatusBadgeView(
                                title: "Running",
                                systemImage: "record.circle.fill",
                                tint: .red
                            )
                        }
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    IconActionButton(
                        title: "Start Timer",
                        systemImage: "play.fill",
                        prominence: .prominent,
                        action: {
                            store.startTimer(projectID: project.id, taskID: task.id)
                        }
                    )
                    .disabled(!store.canStartTimer(projectID: project.id, taskID: task.id))

                    IconActionButton(
                        title: "Stop Timer",
                        systemImage: "stop.fill",
                        action: {
                            store.stopTimer()
                        }
                    )
                    .disabled(!store.isActiveTask(projectID: project.id, taskID: task.id))

                    IconActionButton(
                        title: task.isCompleted ? "Reopen Task" : "Complete Task",
                        systemImage: task.isCompleted ? "arrow.counterclockwise" : "checkmark",
                        action: {
                            if task.isCompleted {
                                store.reopenTask(projectID: project.id, taskID: task.id)
                            } else {
                                store.completeTask(projectID: project.id, taskID: task.id)
                            }
                        }
                    )
                    .disabled(store.isActiveTask(projectID: project.id, taskID: task.id))
                }
            }

            if store.isActiveTask(projectID: project.id, taskID: task.id) {
                HStack(spacing: 6) {
                    Image(systemName: "record.circle.fill")
                        .foregroundStyle(.red)
                        .imageScale(.small)

                    Text(store.activeClockText)
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor))
                )
            } else if store.isRunning {
                Label("Another task is currently running. Stop it before starting this one.", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if project.isCompleted {
                Label("Reopen the project before tracking more time on this task.", systemImage: "lock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func stats(task: WorkTask) -> some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Records")
                .font(.title3.bold())

            if task.records.isEmpty {
                Text("No time records yet. Start and stop the timer to build its history.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.thinMaterial)
                    )
            } else {
                VStack(spacing: 10) {
                    ForEach(task.orderedRecords) { record in
                        TaskRecordRowView(
                            record: record,
                            onDelete: {
                                store.deleteRecord(projectID: project.id, taskID: task.id, recordID: record.id)
                            }
                        )
                    }
                }
            }
        }
    }
}
