//
//  ProjectDetailView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var store: TimerStore

    let projectID: UUID
    let onCreateTask: () -> Void
    let onSelectTask: (UUID) -> Void

    private let statColumns = [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 10)]

    var body: some View {
        if let project = store.project(with: projectID) {
            GlassEffectContainer(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    header(for: project)
                    stats(for: project)
                    tasksSection(for: project)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView(onCreateProject: {})
        }
    }

    private func header(for project: WorkProject) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(project.name)
                        .font(.title2.weight(.semibold))

                    HStack(spacing: 8) {
                        StatusBadgeView(
                            title: project.isCompleted ? "Completed" : "Active",
                            systemImage: project.isCompleted ? "checkmark.circle.fill" : "folder.fill",
                            tint: project.isCompleted ? .secondary : .accentColor
                        )

                        if store.isActiveProject(project.id) {
                            StatusBadgeView(
                                title: "Timer Running",
                                systemImage: "record.circle.fill",
                                tint: .red
                            )
                        }
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    IconActionButton(
                        title: "New Task",
                        systemImage: "plus",
                        action: onCreateTask
                    )
                    .disabled(project.isCompleted)

                    IconActionButton(
                        title: project.isCompleted ? "Reopen Project" : "Complete Project",
                        systemImage: project.isCompleted ? "arrow.counterclockwise" : "checkmark",
                        action: {
                            if project.isCompleted {
                                store.reopenProject(project.id)
                            } else {
                                store.completeProject(project.id)
                            }
                        }
                    )
                    .disabled(store.isActiveProject(project.id))
                }
            }

            if store.isActiveProject(project.id) {
                Label("Timer is running on a task in this project.", systemImage: "record.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func stats(for project: WorkProject) -> some View {
        LazyVGrid(columns: statColumns, alignment: .leading, spacing: 10) {
            DetailStatCardView(title: "Total Time", value: project.totalDurationText, detail: "All task records")
            DetailStatCardView(title: "Today", value: project.todayDurationText, detail: "\(project.totalRecordCount) records")
            DetailStatCardView(title: "Open Tasks", value: "\(project.openTaskCount)", detail: "\(project.completedTaskCount) completed")
            DetailStatCardView(title: "Tasks", value: "\(project.tasks.count)", detail: project.createdAt.formatted(date: .abbreviated, time: .omitted))
        }
    }

    private func tasksSection(for project: WorkProject) -> some View {
        let orderedTasks = project.orderedTasks

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
                    .font(.headline)

                Spacer()

                IconActionButton(
                    title: "New Task",
                    systemImage: "plus",
                    action: onCreateTask
                )
                .disabled(project.isCompleted)
            }

            if orderedTasks.isEmpty {
                Text("No tasks yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(orderedTasks.enumerated()), id: \.element.id) { index, task in
                            ProjectTaskListRowView(
                                task: task,
                                isRunning: store.isActiveTask(projectID: project.id, taskID: task.id),
                                onOpen: {
                                    onSelectTask(task.id)
                                }
                            )

                            if index < orderedTasks.count - 1 {
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
