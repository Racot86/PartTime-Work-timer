//
//  ContentView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TimerStore

    @State private var selection: SidebarSelection?
    @State private var isPresentingProjectSheet = false
    @State private var taskComposerContext: TaskComposerContext?

    var body: some View {
        NavigationSplitView {
            ProjectsSidebarView(
                selection: $selection,
                isPresentingProjectSheet: $isPresentingProjectSheet
            )
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1080, minHeight: 700)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $isPresentingProjectSheet) {
            CreateProjectSheetView { projectName in
                if let projectID = store.createProject(name: projectName) {
                    selection = .project(projectID)
                }
            }
        }
        .sheet(item: $taskComposerContext) { context in
            if let project = store.project(with: context.projectID) {
                CreateTaskSheetView(projectName: project.name) { taskName in
                    if let taskID = store.createTask(name: taskName, in: context.projectID) {
                        selection = .task(projectID: context.projectID, taskID: taskID)
                    }
                }
            }
        }
        .onAppear(perform: ensureInitialSelection)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selection {
        case .project(let projectID):
            ProjectDetailView(
                projectID: projectID,
                onCreateTask: {
                    taskComposerContext = TaskComposerContext(projectID: projectID)
                },
                onSelectTask: { taskID in
                    selection = .task(projectID: projectID, taskID: taskID)
                }
            )
        case .task(let projectID, let taskID):
            TaskDetailView(
                projectID: projectID,
                taskID: taskID,
                onShowProject: {
                    selection = .project(projectID)
                }
            )
        case .none:
            WorkspaceOverviewView(
                onCreateProject: {
                    isPresentingProjectSheet = true
                }
            )
        }
    }

    private func ensureInitialSelection() {
        if let selection {
            switch selection {
            case .project(let projectID) where store.projectExists(projectID):
                return
            case .task(let projectID, let taskID) where store.taskExists(projectID: projectID, taskID: taskID):
                return
            default:
                break
            }
        }

        selection = store.recommendedSelection()
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerStore.preview)
}
