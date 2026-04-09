//
//  WorkTask.swift
//  PartTime Work timer
//

import Foundation
import SwiftData

@Model
final class WorkTask: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var completedAt: Date?
    var project: WorkProject?
    @Relationship(deleteRule: .cascade) var records: [TimeRecord]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        project: WorkProject? = nil,
        records: [TimeRecord] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.project = project
        self.records = []

        for record in records {
            record.task = self
            self.records.append(record)
        }
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var totalDuration: TimeInterval {
        records.reduce(0) { $0 + $1.duration }
    }

    var totalDurationText: String {
        WorkTimerFormatter.shortDuration(totalDuration)
    }

    var todayDuration: TimeInterval {
        records
            .filter { Calendar.current.isDateInToday($0.startedAt) }
            .reduce(0) { $0 + $1.duration }
    }

    var todayDurationText: String {
        WorkTimerFormatter.shortDuration(todayDuration)
    }

    var latestRecord: TimeRecord? {
        orderedRecords.first
    }

    var recordCount: Int {
        records.count
    }

    var orderedRecords: [TimeRecord] {
        records.sorted { $0.startedAt > $1.startedAt }
    }
}
