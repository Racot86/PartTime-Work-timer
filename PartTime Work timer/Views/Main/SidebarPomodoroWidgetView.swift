//
//  SidebarPomodoroWidgetView.swift
//  PartTime Work timer
//

import SwiftUI

struct SidebarPomodoroWidgetView: View {
    @EnvironmentObject private var store: TimerStore

    var body: some View {
        let snapshot = store.pomodoroSnapshot

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Label(snapshot.phaseTitle, systemImage: snapshot.symbolName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor(for: snapshot))

                Spacer()

                Toggle(
                    "Pomodoro",
                    isOn: Binding(
                        get: { snapshot.isEnabled },
                        set: { store.setPomodoroEnabled($0) }
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.mini)
            }

            Text(snapshot.detailText)
                .font(.caption)
                .foregroundStyle(snapshot.showsVisualAlert ? WorkTimerGlassPalette.restIcon : .secondary)
                .lineLimit(2)

            Text(snapshot.scheduleText)
                .font(.caption2)
                .foregroundStyle(.tertiary)

            if snapshot.isEnabled && snapshot.isRunning {
                Text(snapshot.countdownText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(snapshot.showsVisualAlert ? WorkTimerGlassPalette.restIcon : .primary)
            }
        }
        .padding(10)
        .glassEffect(
            .regular.tint(WorkTimerGlassPalette.neutralSurfaceTint),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    private func accentColor(for snapshot: PomodoroService.Snapshot) -> Color {
        if !snapshot.isEnabled {
            return .secondary
        }

        switch snapshot.phase {
        case .idle:
            return .secondary
        case .work:
            return WorkTimerGlassPalette.accentIcon
        case .rest:
            return WorkTimerGlassPalette.restIcon
        }
    }
}
