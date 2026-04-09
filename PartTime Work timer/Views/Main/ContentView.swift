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
            ProjectsSidebarView(selection: $selection)
                .toolbar {
                    SidebarToolbarContent(
                        selectedProject: selectedProject,
                        onCreateProject: {
                            isPresentingProjectSheet = true
                        },
                        onCreateTask: { projectID in
                            taskComposerContext = TaskComposerContext(projectID: projectID)
                        }
                    )
                }
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .navigationTitle(windowTitle)
        .navigationSubtitle(windowSubtitle)
        .toolbarRole(.editor)
        .toolbar {
            MainToolbarContent(
                store: store,
                selectedProject: selectedProject,
                selectedTask: selectedTask
            )
        }
        .frame(minWidth: 980, minHeight: 620)
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
        .onAppear(perform: syncWindowTitle)
        .onChange(of: windowTitleToken) { _, _ in
            syncWindowTitle()
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selection {
        case .project(let projectID):
            ProjectDetailView(
                projectID: projectID,
                onSelectTask: { taskID in
                    selection = .task(projectID: projectID, taskID: taskID)
                }
            )
        case .task(let projectID, let taskID):
            TaskDetailView(
                projectID: projectID,
                taskID: taskID
            )
        case .none:
            WorkspaceOverviewView()
        }
    }

    private var selectedProject: WorkProject? {
        switch selection {
        case .project(let projectID):
            store.project(with: projectID)
        case .task(let projectID, _):
            store.project(with: projectID)
        case .none:
            nil
        }
    }

    private var selectedTask: WorkTask? {
        guard case .task(let projectID, let taskID) = selection else {
            return nil
        }

        return store.task(projectID: projectID, taskID: taskID)
    }

    private var windowTitle: String {
        if let selectedTask {
            return selectedTask.name
        }

        if let selectedProject {
            return selectedProject.name
        }

        return "Overview"
    }

    private var windowSubtitle: String {
        if selectedTask != nil, let selectedProject {
            return selectedProject.name
        }

        if let selectedProject {
            return selectedProject.isCompleted ? "Completed Project" : "Project"
        }

        return "Part-Time Work Timer"
    }

    private var windowTitleToken: String {
        "\(windowTitle)|\(windowSubtitle)"
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

    private func syncWindowTitle() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateMainWindowTitle(title: windowTitle, subtitle: windowSubtitle)
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerStore.preview)
}
