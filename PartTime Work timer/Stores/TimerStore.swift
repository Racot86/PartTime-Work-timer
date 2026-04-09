//
//  TimerStore.swift
//  PartTime Work timer
//

import AppKit
import Combine
import Foundation
import SwiftData

@MainActor
final class TimerStore: ObservableObject {
    @Published private(set) var projects: [WorkProject] = []
    @Published private(set) var activeTimer: ActiveTimer?
    @Published private(set) var now = Date()
    @Published private(set) var pomodoroSnapshot = PomodoroService.Snapshot.make(
        isEnabled: true,
        isRunning: false,
        workDuration: 25 * 60,
        restDuration: 5 * 60,
        transitionCount: 0
    )

    private let modelContext: ModelContext
    private let legacyStateStore: TimerStateFileStore
    private let migrationUserDefaults: UserDefaults
    private let pomodoroService: PomodoroService
    private let legacyStorageKey = "partTimeWorkTimer.state"
    private var clockCancellable: AnyCancellable?
    private var terminationCancellable: AnyCancellable?

    init(
        modelContext: ModelContext,
        legacyStateStore: TimerStateFileStore? = nil,
        pomodoroService: PomodoroService? = nil,
        migrationUserDefaults: UserDefaults = .standard,
        loadPersistedState: Bool = true
    ) {
        self.modelContext = modelContext
        self.legacyStateStore = legacyStateStore ?? TimerStateFileStore()
        self.migrationUserDefaults = migrationUserDefaults
        self.pomodoroService = pomodoroService ?? PomodoroService(defaults: migrationUserDefaults)

        if loadPersistedState {
            migrateLegacyStateIfNeeded()
            reloadData()
        }

        startClock()
        observeApplicationTermination()
        refreshPomodoroState()
    }

    deinit {
        clockCancellable?.cancel()
        terminationCancellable?.cancel()
    }

    var isRunning: Bool {
        activeTimer != nil
    }

    var activeDuration: TimeInterval {
        guard let activeTimer else { return 0 }
        return now.timeIntervalSince(activeTimer.startedAt)
    }

    var activeClockText: String {
        WorkTimerFormatter.clock(activeDuration)
    }

    var totalDuration: TimeInterval {
        projects.reduce(0) { $0 + $1.totalDuration }
    }

    var totalDurationText: String {
        WorkTimerFormatter.shortDuration(totalDuration)
    }

    var todayDuration: TimeInterval {
        projects.reduce(0) { $0 + $1.todayDuration }
    }

    var todayDurationText: String {
        WorkTimerFormatter.shortDuration(todayDuration)
    }

    var totalRecordCount: Int {
        projects.reduce(0) { $0 + $1.totalRecordCount }
    }

    var completedProjectCount: Int {
        projects.filter(\.isCompleted).count
    }

    var openProjectCount: Int {
        projects.count - completedProjectCount
    }

    var activeProject: WorkProject? {
        guard let projectID = activeTimer?.projectID else { return nil }
        return project(with: projectID)
    }

    var activeTask: WorkTask? {
        guard let activeTimer else { return nil }
        return task(projectID: activeTimer.projectID, taskID: activeTimer.taskID)
    }

    var activeContextTitle: String {
        guard let activeProject, let activeTask else {
            return "Active Timer"
        }

        return "\(activeProject.name) • \(activeTask.name)"
    }

    var pomodoroEnabled: Bool {
        pomodoroSnapshot.isEnabled
    }

    func project(with id: UUID) -> WorkProject? {
        projects.first { $0.id == id }
    }

    func task(projectID: UUID, taskID: UUID) -> WorkTask? {
        project(with: projectID)?.tasks.first { $0.id == taskID }
    }

    func isActiveProject(_ projectID: UUID) -> Bool {
        activeTimer?.projectID == projectID
    }

    func isActiveTask(projectID: UUID, taskID: UUID) -> Bool {
        activeTimer?.projectID == projectID && activeTimer?.taskID == taskID
    }

    func canStartTimer(projectID: UUID, taskID: UUID) -> Bool {
        guard !isRunning else { return false }
        guard let project = project(with: projectID), let task = task(projectID: projectID, taskID: taskID) else {
            return false
        }

        return !project.isCompleted && !task.isCompleted
    }

    func createProject(name: String) -> UUID? {
        let normalizedName = normalizedName(from: name)
        guard !normalizedName.isEmpty else { return nil }

        let project = WorkProject(name: normalizedName)
        modelContext.insert(project)

        guard saveChanges() else { return nil }
        return project.id
    }

    func createTask(name: String, in projectID: UUID) -> UUID? {
        let normalizedName = normalizedName(from: name)
        guard !normalizedName.isEmpty else { return nil }
        guard let project = project(with: projectID), !project.isCompleted else { return nil }

        let task = WorkTask(name: normalizedName)
        project.tasks.append(task)
        modelContext.insert(task)

        guard saveChanges() else { return nil }
        return task.id
    }

    func startTimer(projectID: UUID, taskID: UUID) {
        guard canStartTimer(projectID: projectID, taskID: taskID) else { return }

        if let timers = try? modelContext.fetch(FetchDescriptor<ActiveTimer>()) {
            for timer in timers {
                modelContext.delete(timer)
            }
        }

        let timer = ActiveTimer(projectID: projectID, taskID: taskID, startedAt: now)
        modelContext.insert(timer)
        _ = saveChanges()
    }

    func stopTimer() {
        stopTimer(at: Date())
    }

    func finalizeActiveTimerIfNeeded() {
        stopTimer(at: Date())
    }

    private func stopTimer(at endDate: Date) {
        guard let activeTimer else { return }

        if let task = task(projectID: activeTimer.projectID, taskID: activeTimer.taskID) {
            let record = TimeRecord(startedAt: activeTimer.startedAt, endedAt: endDate)
            task.records.append(record)
            modelContext.insert(record)
        }

        modelContext.delete(activeTimer)
        _ = saveChanges()
    }

    func completeTask(projectID: UUID, taskID: UUID) {
        guard !isActiveTask(projectID: projectID, taskID: taskID) else { return }
        guard let task = task(projectID: projectID, taskID: taskID) else { return }

        task.completedAt = task.completedAt ?? now
        _ = saveChanges()
    }

    func reopenTask(projectID: UUID, taskID: UUID) {
        guard let project = project(with: projectID), let task = task(projectID: projectID, taskID: taskID) else { return }

        project.completedAt = nil
        task.completedAt = nil
        _ = saveChanges()
    }

    func projectExists(_ projectID: UUID) -> Bool {
        project(with: projectID) != nil
    }

    func taskExists(projectID: UUID, taskID: UUID) -> Bool {
        task(projectID: projectID, taskID: taskID) != nil
    }

    func recommendedSelection() -> SidebarSelection? {
        if let activeTimer, taskExists(projectID: activeTimer.projectID, taskID: activeTimer.taskID) {
            return .task(projectID: activeTimer.projectID, taskID: activeTimer.taskID)
        }

        if let firstProject = projects.first {
            return .project(firstProject.id)
        }

        return nil
    }

    func completeProject(_ projectID: UUID) {
        guard !isActiveProject(projectID), let project = project(with: projectID) else { return }

        let completionDate = now
        project.completedAt = project.completedAt ?? completionDate

        for task in project.tasks where task.completedAt == nil {
            task.completedAt = completionDate
        }

        _ = saveChanges()
    }

    func reopenProject(_ projectID: UUID) {
        guard let project = project(with: projectID) else { return }

        project.completedAt = nil
        _ = saveChanges()
    }

    func deleteRecord(projectID: UUID, taskID: UUID, recordID: UUID) {
        guard
            let task = task(projectID: projectID, taskID: taskID),
            let record = task.records.first(where: { $0.id == recordID })
        else {
            return
        }

        task.records.removeAll { $0.id == recordID }
        modelContext.delete(record)
        _ = saveChanges()
    }

    func setPomodoroEnabled(_ isEnabled: Bool) {
        pomodoroService.setEnabled(isEnabled)
        refreshPomodoroState()
    }

    private func migrateLegacyStateIfNeeded() {
        if hasPersistedData() {
            return
        }

        if let legacyFileState = try? legacyStateStore.loadState(), importLegacyState(legacyFileState) {
            try? legacyStateStore.deleteStateFileIfPresent()
            migrationUserDefaults.removeObject(forKey: legacyStorageKey)
            return
        }

        guard let data = migrationUserDefaults.data(forKey: legacyStorageKey) else { return }

        if let legacyState = try? JSONDecoder().decode(PersistedTimerState.self, from: data), importLegacyState(legacyState) {
            migrationUserDefaults.removeObject(forKey: legacyStorageKey)
            return
        }

        if let legacyFlatState = try? JSONDecoder().decode(LegacyFlatTimerState.self, from: data), importLegacyFlatState(legacyFlatState) {
            migrationUserDefaults.removeObject(forKey: legacyStorageKey)
        }
    }

    private func hasPersistedData() -> Bool {
        let existingProjects = (try? modelContext.fetch(FetchDescriptor<WorkProject>())) ?? []
        if !existingProjects.isEmpty {
            return true
        }

        let existingTimers = (try? modelContext.fetch(FetchDescriptor<ActiveTimer>())) ?? []
        return !existingTimers.isEmpty
    }

    @discardableResult
    private func importLegacyState(_ state: PersistedTimerState) -> Bool {
        var taskIDs = Set<UUID>()

        for project in state.projects {
            let importedProject = WorkProject(
                id: project.id,
                name: project.name,
                createdAt: project.createdAt,
                completedAt: project.completedAt
            )
            modelContext.insert(importedProject)

            for task in project.tasks {
                let importedTask = WorkTask(
                    id: task.id,
                    name: task.name,
                    createdAt: task.createdAt,
                    completedAt: task.completedAt
                )
                importedProject.tasks.append(importedTask)
                modelContext.insert(importedTask)
                taskIDs.insert(importedTask.id)

                for record in task.records {
                    let importedRecord = TimeRecord(
                        id: record.id,
                        startedAt: record.startedAt,
                        endedAt: record.endedAt
                    )
                    importedTask.records.append(importedRecord)
                    modelContext.insert(importedRecord)
                }
            }
        }

        if let activeTimer = state.activeTimer, taskIDs.contains(activeTimer.taskID) {
            modelContext.insert(
                ActiveTimer(
                    id: activeTimer.id,
                    projectID: activeTimer.projectID,
                    taskID: activeTimer.taskID,
                    startedAt: activeTimer.startedAt
                )
            )
        }

        return saveChanges()
    }

    @discardableResult
    private func importLegacyFlatState(_ legacy: LegacyFlatTimerState) -> Bool {
        guard !legacy.entries.isEmpty || legacy.activeTimer != nil else {
            return false
        }

        let createdAt = legacy.entries.map(\.startedAt).min() ?? legacy.activeTimer?.startedAt ?? .now
        let project = WorkProject(name: "Imported Sessions", createdAt: createdAt)
        modelContext.insert(project)

        var tasksByName: [String: WorkTask] = [:]

        for entry in legacy.entries {
            let taskName = normalizedName(from: entry.job).isEmpty ? "Imported Task" : normalizedName(from: entry.job)

            let task: WorkTask
            if let existingTask = tasksByName[taskName] {
                task = existingTask
            } else {
                let newTask = WorkTask(name: taskName, createdAt: entry.startedAt)
                project.tasks.append(newTask)
                modelContext.insert(newTask)
                tasksByName[taskName] = newTask
                task = newTask
            }

            let record = TimeRecord(id: entry.id, startedAt: entry.startedAt, endedAt: entry.endedAt)
            task.records.append(record)
            modelContext.insert(record)
        }

        if let legacyActiveTimer = legacy.activeTimer {
            let taskName = normalizedName(from: legacyActiveTimer.job).isEmpty ? "Imported Task" : normalizedName(from: legacyActiveTimer.job)

            let task: WorkTask
            if let existingTask = tasksByName[taskName] {
                task = existingTask
            } else {
                let newTask = WorkTask(name: taskName, createdAt: legacyActiveTimer.startedAt)
                project.tasks.append(newTask)
                modelContext.insert(newTask)
                tasksByName[taskName] = newTask
                task = newTask
            }

            modelContext.insert(
                ActiveTimer(
                    id: legacyActiveTimer.id,
                    projectID: project.id,
                    taskID: task.id,
                    startedAt: legacyActiveTimer.startedAt
                )
            )
        }

        return saveChanges()
    }

    private func reloadData() {
        let fetchedProjects = (try? modelContext.fetch(FetchDescriptor<WorkProject>())) ?? []
        projects = sortedProjects(fetchedProjects)

        var fetchedTimers = (try? modelContext.fetch(FetchDescriptor<ActiveTimer>())) ?? []
        fetchedTimers.sort { $0.startedAt > $1.startedAt }

        if fetchedTimers.count > 1 {
            for timer in fetchedTimers.dropFirst() {
                modelContext.delete(timer)
            }
            try? modelContext.save()
            fetchedTimers = Array(fetchedTimers.prefix(1))
        }

        activeTimer = fetchedTimers.first
        refreshPomodoroState()
    }

    private func sortedProjects(_ projects: [WorkProject]) -> [WorkProject] {
        projects.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }

            return lhs.createdAt > rhs.createdAt
        }
    }

    @discardableResult
    private func saveChanges() -> Bool {
        do {
            try modelContext.save()
            reloadData()
            return true
        } catch {
            modelContext.rollback()
            reloadData()
            return false
        }
    }

    private func startClock() {
        clockCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] newDate in
                self?.now = newDate
                self?.refreshPomodoroState()
            }
    }

    private func observeApplicationTermination() {
        terminationCancellable = NotificationCenter.default
            .publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.finalizeActiveTimerIfNeeded()
            }
    }

    private func normalizedName(from value: String) -> String {
        value
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func refreshPomodoroState() {
        pomodoroSnapshot = pomodoroService.update(activeTimer: activeTimer, now: now)
    }
}

extension TimerStore {
    static var preview: TimerStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer

        do {
            container = try ModelContainer(
                for: WorkProject.self,
                WorkTask.self,
                TimeRecord.self,
                ActiveTimer.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create preview model container: \(error)")
        }

        let store = TimerStore(
            modelContext: container.mainContext,
            loadPersistedState: false
        )

        let websiteProject = WorkProject(
            name: "Website Retainer",
            createdAt: .now.addingTimeInterval(-200_000)
        )
        let homepageTask = WorkTask(
            name: "Homepage Refresh",
            createdAt: .now.addingTimeInterval(-100_000)
        )
        let clientReportTask = WorkTask(
            name: "Client Report",
            createdAt: .now.addingTimeInterval(-90_000),
            completedAt: .now.addingTimeInterval(-43_200)
        )

        websiteProject.tasks.append(contentsOf: [homepageTask, clientReportTask])

        homepageTask.records.append(
            contentsOf: [
                TimeRecord(
                    startedAt: .now.addingTimeInterval(-14_400),
                    endedAt: .now.addingTimeInterval(-11_700)
                ),
                TimeRecord(
                    startedAt: .now.addingTimeInterval(-8_000),
                    endedAt: .now.addingTimeInterval(-6_500)
                )
            ]
        )

        clientReportTask.records.append(
            TimeRecord(
                startedAt: .now.addingTimeInterval(-50_000),
                endedAt: .now.addingTimeInterval(-47_000)
            )
        )

        let operationsProject = WorkProject(
            name: "Internal Ops",
            createdAt: .now.addingTimeInterval(-160_000)
        )
        let invoiceTask = WorkTask(
            name: "Weekly Invoice",
            createdAt: .now.addingTimeInterval(-70_000)
        )

        operationsProject.tasks.append(invoiceTask)
        invoiceTask.records.append(
            TimeRecord(
                startedAt: .now.addingTimeInterval(-4_200),
                endedAt: .now.addingTimeInterval(-1_800)
            )
        )

        container.mainContext.insert(websiteProject)
        container.mainContext.insert(operationsProject)

        if let previewTask = websiteProject.tasks.first {
            container.mainContext.insert(
                ActiveTimer(
                    projectID: websiteProject.id,
                    taskID: previewTask.id,
                    startedAt: .now.addingTimeInterval(-1_200)
                )
            )
        }

        try? container.mainContext.save()
        store.reloadData()

        return store
    }
}
