//
//  PomodoroService.swift
//  PartTime Work timer
//

import AppKit
import Foundation

@MainActor
final class PomodoroService {
    enum Phase: String, Equatable, Sendable {
        case idle
        case work
        case rest
    }

    struct Snapshot: Equatable, Sendable {
        let isEnabled: Bool
        let isRunning: Bool
        let phase: Phase
        let timeRemaining: TimeInterval
        let workDuration: TimeInterval
        let restDuration: TimeInterval
        let transitionCount: Int

        var phaseTitle: String {
            switch phase {
            case .idle:
                return isEnabled ? "Pomodoro Ready" : "Pomodoro Off"
            case .work:
                return "Work Block"
            case .rest:
                return "Break Block"
            }
        }

        var detailText: String {
            if !isEnabled {
                return isRunning ? "Task timer running without beeps." : "Turn on 25/5 beeps."
            }

            if !isRunning {
                return "Starts when a task timer starts."
            }

            switch phase {
            case .idle:
                return "Waiting for a running task."
            case .work:
                return "Break beep in \(countdownText)"
            case .rest:
                return "Check the timer. Work beep in \(countdownText)"
            }
        }

        var scheduleText: String {
            "\(Int(workDuration / 60))m work • \(Int(restDuration / 60))m rest"
        }

        var countdownText: String {
            WorkTimerFormatter.clock(timeRemaining)
        }

        var symbolName: String {
            switch phase {
            case .idle:
                return isEnabled ? "timer" : "speaker.slash"
            case .work:
                return "timer"
            case .rest:
                return "cup.and.saucer.fill"
            }
        }

        var showsVisualAlert: Bool {
            isEnabled && isRunning && phase == .rest
        }

        static func make(
            isEnabled: Bool,
            isRunning: Bool,
            phase: Phase = .idle,
            timeRemaining: TimeInterval = 0,
            workDuration: TimeInterval,
            restDuration: TimeInterval,
            transitionCount: Int
        ) -> Snapshot {
            Snapshot(
                isEnabled: isEnabled,
                isRunning: isRunning,
                phase: phase,
                timeRemaining: timeRemaining,
                workDuration: workDuration,
                restDuration: restDuration,
                transitionCount: transitionCount
            )
        }
    }

    private let defaults: UserDefaults
    private let enabledKey: String
    private let workDuration: TimeInterval
    private let restDuration: TimeInterval
    private let workSound: NSSound?
    private let restSound: NSSound?

    private var lastTimerID: UUID?
    private var lastSegmentIndex: Int?
    private var transitionCount = 0

    init(
        defaults: UserDefaults = .standard,
        enabledKey: String = "pomodoro.enabled",
        workDuration: TimeInterval = 25 * 60,
        restDuration: TimeInterval = 5 * 60
    ) {
        self.defaults = defaults
        self.enabledKey = enabledKey
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.workSound = Self.loadSound(
            named: "work_sound",
            withExtension: "wav",
            fallbackNamed: "Hero"
        )
        self.restSound = Self.loadSound(
            named: "rest_sound",
            withExtension: "wav",
            fallbackNamed: "Glass"
        )
    }

    var isEnabled: Bool {
        defaults.object(forKey: enabledKey) as? Bool ?? true
    }

    func setEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: enabledKey)

        if !isEnabled {
            resetTracking()
        }
    }

    func update(activeTimer: ActiveTimer?, now: Date) -> Snapshot {
        guard let activeTimer else {
            resetTracking()
            return Snapshot.make(
                isEnabled: isEnabled,
                isRunning: false,
                workDuration: workDuration,
                restDuration: restDuration,
                transitionCount: transitionCount
            )
        }

        guard isEnabled else {
            resetTracking(keepingTransitions: true)
            return Snapshot.make(
                isEnabled: false,
                isRunning: true,
                workDuration: workDuration,
                restDuration: restDuration,
                transitionCount: transitionCount
            )
        }

        let elapsed = max(0, now.timeIntervalSince(activeTimer.startedAt))
        let cycleDuration = workDuration + restDuration
        let completedCycles = Int(elapsed / cycleDuration)
        let positionInCycle = elapsed.truncatingRemainder(dividingBy: cycleDuration)

        let phase: Phase
        let timeRemaining: TimeInterval
        let segmentIndex: Int

        if positionInCycle < workDuration {
            phase = .work
            timeRemaining = workDuration - positionInCycle
            segmentIndex = completedCycles * 2
        } else {
            phase = .rest
            timeRemaining = restDuration - (positionInCycle - workDuration)
            segmentIndex = completedCycles * 2 + 1
        }

        if lastTimerID != activeTimer.id {
            lastTimerID = activeTimer.id
            lastSegmentIndex = segmentIndex
        } else if lastSegmentIndex != segmentIndex {
            lastSegmentIndex = segmentIndex
            transitionCount += 1
            playSound(for: phase)
        }

        return Snapshot.make(
            isEnabled: true,
            isRunning: true,
            phase: phase,
            timeRemaining: timeRemaining,
            workDuration: workDuration,
            restDuration: restDuration,
            transitionCount: transitionCount
        )
    }

    private func playSound(for phase: Phase) {
        switch phase {
        case .work:
            workSound?.stop()
            workSound?.play()
        case .rest:
            restSound?.stop()
            restSound?.play()
        case .idle:
            break
        }
    }

    private func resetTracking(keepingTransitions: Bool = false) {
        lastTimerID = nil
        lastSegmentIndex = nil

        if !keepingTransitions {
            transitionCount = 0
        }
    }

    private static func loadSound(
        named resourceName: String,
        withExtension fileExtension: String,
        fallbackNamed fallbackName: String
    ) -> NSSound? {
        if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {
            return NSSound(contentsOf: url, byReference: false)
        }

        if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension, subdirectory: "sounds") {
            return NSSound(contentsOf: url, byReference: false)
        }

        return NSSound(named: NSSound.Name(fallbackName))
    }
}
