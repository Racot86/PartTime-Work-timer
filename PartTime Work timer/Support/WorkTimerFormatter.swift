//
//  WorkTimerFormatter.swift
//  PartTime Work timer
//

import Foundation

enum WorkTimerFormatter {
    private static let clockFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    private static let shortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        formatter.zeroFormattingBehavior = [.dropLeading]
        return formatter
    }()

    static func clock(_ interval: TimeInterval) -> String {
        clockFormatter.string(from: max(0, interval)) ?? "00:00:00"
    }

    static func shortDuration(_ interval: TimeInterval) -> String {
        shortFormatter.string(from: max(0, interval)) ?? "0s"
    }
}
