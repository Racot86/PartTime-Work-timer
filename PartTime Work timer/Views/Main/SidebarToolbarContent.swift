//
//  SidebarToolbarContent.swift
//  PartTime Work timer
//

import SwiftUI

struct SidebarToolbarContent: ToolbarContent {
    let selectedProject: WorkProject?
    let onCreateProject: () -> Void
    let onCreateTask: (UUID) -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .secondaryAction) {
            Button(action: onCreateProject) {
                ToolbarActionLabelView(
                    title: "New Project",
                    systemImage: "folder.badge.plus"
                )
            }
            .help("New Project")

            if let project = selectedProject {
                Button(
                    action: {
                        onCreateTask(project.id)
                    }
                ) {
                    ToolbarActionLabelView(
                        title: "New Task",
                        systemImage: "checklist"
                    )
                }
                .help("New Task")
                .disabled(project.isCompleted)
            }
        }
    }
}
