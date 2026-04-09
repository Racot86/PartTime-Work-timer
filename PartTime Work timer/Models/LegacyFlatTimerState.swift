//
//  LegacyFlatTimerState.swift
//  PartTime Work timer
//

import Foundation

struct LegacyFlatTimerState: Codable {
    var entries: [LegacyTrackedSession]
    var activeTimer: LegacyFlatActiveTimer?
    var draftJob: String
}

struct LegacyTrackedSession: Codable {
    let id: UUID
    let job: String
    let startedAt: Date
    let endedAt: Date
}

struct LegacyFlatActiveTimer: Codable {
    let id: UUID
    let job: String
    let startedAt: Date
}
