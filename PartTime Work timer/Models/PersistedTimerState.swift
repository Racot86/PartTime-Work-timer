//
//  PersistedTimerState.swift
//  PartTime Work timer
//

import Foundation

// Legacy JSON snapshot used only for one-time migration into SwiftData.
struct PersistedTimerState: Codable {
    var projects: [PersistedProject]
    var activeTimer: PersistedActiveTimer?
}

struct PersistedProject: Codable {
    let id: UUID
    var name: String
    let createdAt: Date
    var completedAt: Date?
    var tasks: [PersistedTask]
}

struct PersistedTask: Codable {
    let id: UUID
    var name: String
    let createdAt: Date
    var completedAt: Date?
    var records: [PersistedTimeRecord]
}

struct PersistedTimeRecord: Codable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
}

struct PersistedActiveTimer: Codable {
    let id: UUID
    let projectID: UUID
    let taskID: UUID
    let startedAt: Date
}
