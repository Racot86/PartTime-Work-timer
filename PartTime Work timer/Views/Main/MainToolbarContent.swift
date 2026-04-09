//
//  MainToolbarContent.swift
//  PartTime Work timer
//

import SwiftUI

struct MainToolbarContent: ToolbarContent {
    let store: TimerStore
    let selectedProject: WorkProject?
    let selectedTask: WorkTask?

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            if let project = selectedProject, let task = selectedTask {
                Button(
                    action: {
                        store.startTimer(projectID: project.id, taskID: task.id)
                    }
                ) {
                    ToolbarActionLabelView(
                        title: "Start Timer",
                        systemImage: "play.fill"
                    )
                }
                .help("Start Timer")
                .disabled(!store.canStartTimer(projectID: project.id, taskID: task.id))

                Button(
                    action: {
                        store.stopTimer()
                    }
                ) {
                    ToolbarActionLabelView(
                        title: "Stop Timer",
                        systemImage: "stop.fill"
                    )
                }
                .help("Stop Timer")
                .disabled(!store.isActiveTask(projectID: project.id, taskID: task.id))

                Button(
                    action: {
                        if task.isCompleted {
                            store.reopenTask(projectID: project.id, taskID: task.id)
                        } else {
                            store.completeTask(projectID: project.id, taskID: task.id)
                        }
                    }
                ) {
                    ToolbarActionLabelView(
                        title: task.isCompleted ? "Reopen Task" : "Complete Task",
                        systemImage: task.isCompleted ? "arrow.counterclockwise" : "checkmark.circle"
                    )
                }
                .help(task.isCompleted ? "Reopen Task" : "Complete Task")
                .disabled(store.isActiveTask(projectID: project.id, taskID: task.id))
            } else if let project = selectedProject {
                Button(
                    action: {
                        if project.isCompleted {
                            store.reopenProject(project.id)
                        } else {
                            store.completeProject(project.id)
                        }
                    }
                ) {
                    ToolbarActionLabelView(
                        title: project.isCompleted ? "Reopen Project" : "Complete Project",
                        systemImage: project.isCompleted ? "arrow.counterclockwise" : "checkmark.circle"
                    )
                }
                .help(project.isCompleted ? "Reopen Project" : "Complete Project")
                .disabled(store.isActiveProject(project.id))
            }
        }
    }
}
