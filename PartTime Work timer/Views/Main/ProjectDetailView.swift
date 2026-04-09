//
//  ProjectDetailView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var store: TimerStore

    let projectID: UUID
    let onSelectTask: (UUID) -> Void

    private let statColumns = [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 10)]

    var body: some View {
        if let project = store.project(with: projectID) {
            GlassEffectContainer(spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    statusStrip(for: project)
                    stats(for: project)
                    tasksSection(for: project)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        } else {
            WorkspaceOverviewView()
        }
    }

    private func statusStrip(for project: WorkProject) -> some View {
        DetailStatusStripView(
            items: projectStatusItems(for: project),
            note: store.isActiveProject(project.id) ? "Timer is running on a task in this project." : nil,
            noteSystemImage: store.isActiveProject(project.id) ? "record.circle.fill" : nil,
            noteTint: WorkTimerGlassPalette.runningIcon
        )
    }

    private func projectStatusItems(for project: WorkProject) -> [DetailStatusItem] {
        var items = [
            DetailStatusItem(
                title: project.isCompleted ? "Completed" : "Active",
                systemImage: project.isCompleted ? "checkmark.circle.fill" : "folder.fill",
                tint: project.isCompleted
                    ? WorkTimerGlassPalette.completionIcon
                    : WorkTimerGlassPalette.accentIcon
            )
        ]

        if store.isActiveProject(project.id) {
            items.append(
                DetailStatusItem(
                    title: "Timer Running",
                    systemImage: "record.circle.fill",
                    tint: WorkTimerGlassPalette.runningIcon
                )
            )
        }

        return items
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
            Text("Tasks")
                .font(.headline)

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
                .glassEffect(
                    .regular.tint(WorkTimerGlassPalette.raisedSurfaceTint),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
