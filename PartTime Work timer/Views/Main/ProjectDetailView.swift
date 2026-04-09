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

    private let statColumns = [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)]

    var body: some View {
        if let project = store.project(with: projectID) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header(for: project)
                    stats(for: project)
                    tasksSection(for: project)
                }
                .padding(18)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView(onCreateProject: {})
        }
    }

    private func header(for project: WorkProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))

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

                    Text("Review task progress, create new tasks, and see the full time spent across this project.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    IconActionButton(
                        title: "New Task",
                        systemImage: "plus",
                        prominence: .prominent,
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
                Label("Stop the active timer before closing this project.", systemImage: "record.circle.fill")
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

    private func stats(for project: WorkProject) -> some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            DetailStatCardView(title: "Total Time", value: project.totalDurationText, detail: "All task records")
            DetailStatCardView(title: "Today", value: project.todayDurationText, detail: "\(project.totalRecordCount) records")
            DetailStatCardView(title: "Open Tasks", value: "\(project.openTaskCount)", detail: "\(project.completedTaskCount) completed")
            DetailStatCardView(title: "Tasks", value: "\(project.tasks.count)", detail: project.createdAt.formatted(date: .abbreviated, time: .omitted))
        }
    }

    private func tasksSection(for project: WorkProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
                    .font(.title3.bold())

                Spacer()

                IconActionButton(
                    title: "New Task",
                    systemImage: "plus",
                    action: onCreateTask
                )
                .disabled(project.isCompleted)
            }

            if project.tasks.isEmpty {
                Text("No tasks yet. Add a task and start tracking time.")
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
                    ForEach(project.orderedTasks) { task in
                        ProjectTaskListRowView(
                            task: task,
                            isRunning: store.isActiveTask(projectID: project.id, taskID: task.id),
                            onOpen: {
                                onSelectTask(task.id)
                            }
                        )
                    }
                }
            }
        }
    }
}
