//
//  ActiveTimer.swift
//  PartTime Work timer
//

import Foundation
import SwiftData

@Model
final class ActiveTimer {
    @Attribute(.unique) var id: UUID
    var projectID: UUID
    var taskID: UUID
    var startedAt: Date

    init(id: UUID = UUID(), projectID: UUID, taskID: UUID, startedAt: Date) {
        self.id = id
        self.projectID = projectID
        self.taskID = taskID
        self.startedAt = startedAt
    }
}
