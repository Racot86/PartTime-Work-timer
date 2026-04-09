//
//  WorkProject.swift
//  PartTime Work timer
//

import Foundation
import SwiftData

@Model
final class WorkProject: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var completedAt: Date?
    @Relationship(deleteRule: .cascade) var tasks: [WorkTask]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        tasks: [WorkTask] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.tasks = []

        for task in tasks {
            task.project = self
            self.tasks.append(task)
        }
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var totalDuration: TimeInterval {
        tasks.reduce(0) { $0 + $1.totalDuration }
    }

    var totalDurationText: String {
        WorkTimerFormatter.shortDuration(totalDuration)
    }

    var totalRecordCount: Int {
        tasks.reduce(0) { $0 + $1.recordCount }
    }

    var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var openTaskCount: Int {
        tasks.count - completedTaskCount
    }

    var todayDuration: TimeInterval {
        tasks.reduce(0) { $0 + $1.todayDuration }
    }

    var todayDurationText: String {
        WorkTimerFormatter.shortDuration(todayDuration)
    }

    var orderedTasks: [WorkTask] {
        tasks.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }

            return lhs.createdAt > rhs.createdAt
        }
    }
}
