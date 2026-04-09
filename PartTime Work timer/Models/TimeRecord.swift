//
//  TimeRecord.swift
//  PartTime Work timer
//

import Foundation
import SwiftData

@Model
final class TimeRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date
    var task: WorkTask?

    init(id: UUID = UUID(), startedAt: Date, endedAt: Date, task: WorkTask? = nil) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.task = task
    }

    var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }

    var durationText: String {
        WorkTimerFormatter.shortDuration(duration)
    }

    var dayText: String {
        startedAt.formatted(date: .abbreviated, time: .omitted)
    }

    var timeRangeText: String {
        "\(startedAt.formatted(date: .omitted, time: .shortened)) - \(endedAt.formatted(date: .omitted, time: .shortened))"
    }
}
