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

    private let statColumns = [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 10)]

    var body: some View {
        if let project = store.project(with: projectID), let task = store.task(projectID: projectID, taskID: taskID) {
            GlassEffectContainer(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    header(project: project, task: task)
                    stats(task: task)
                    recordsSection(project: project, task: task)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView(onCreateProject: {})
        }
    }

    private func header(project: WorkProject, task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Button(action: onShowProject) {
                        Label(project.name, systemImage: "folder")
                    }
                    .buttonStyle(.link)
                    .controlSize(.small)

                    Text(task.name)
                        .font(.title2.weight(.semibold))

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
                Label(store.activeClockText, systemImage: "record.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                    .monospacedDigit()
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
        .padding(12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
