//
//  ProjectsSidebarView.swift
//  PartTime Work timer
//

import SwiftUI

struct ProjectsSidebarView: View {
    @EnvironmentObject private var store: TimerStore

    @Binding var selection: SidebarSelection?
    @Binding var isPresentingProjectSheet: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            List(selection: $selection) {
                if store.projects.isEmpty {
                    Text("Create a project to start tracking time.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.projects) { project in
                        NavigationLink(value: SidebarSelection.project(project.id)) {
                            SidebarProjectRowView(
                                project: project,
                                isRunning: store.isActiveProject(project.id)
                            )
                        }

                        ForEach(project.orderedTasks) { task in
                            NavigationLink(value: SidebarSelection.task(projectID: project.id, taskID: task.id)) {
                                SidebarTaskRowView(
                                    task: task,
                                    isRunning: store.isActiveTask(projectID: project.id, taskID: task.id)
                                )
                            }
                            .padding(.leading, 18)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .environment(\.defaultMinListRowHeight, 22)

            Divider()

            SidebarPomodoroWidgetView()
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        }
    }

    private var header: some View {
        HStack {
            Text("Projects")
                .font(.headline.bold())

            Spacer()

            IconActionButton(
                title: "New Project",
                systemImage: "plus",
                action: {
                    isPresentingProjectSheet = true
                }
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
