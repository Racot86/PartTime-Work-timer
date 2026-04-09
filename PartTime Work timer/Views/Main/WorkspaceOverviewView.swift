//
//  WorkspaceOverviewView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct WorkspaceOverviewView: View {
    @EnvironmentObject private var store: TimerStore

    private let statColumns = [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 10)]

    var body: some View {
        ScrollView {
            GlassEffectContainer(spacing: 12) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    statsStack
                }
            }
            .padding(16)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Work Timer")
                .font(.title2.weight(.semibold))

            if store.isRunning {
                Label("\(store.activeContextTitle)  \(store.activeClockText)", systemImage: "record.circle.fill")
                    .font(.callout)
                    .foregroundStyle(WorkTimerGlassPalette.runningIcon)
                    .monospacedDigit()
                    .lineLimit(1)
            } else {
                Text("Create a project or select one from the sidebar.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassEffect(
            .regular.tint(WorkTimerGlassPalette.neutralSurfaceTint),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var statsStack: some View {
        LazyVGrid(columns: statColumns, alignment: .leading, spacing: 10) {
            DetailStatCardView(title: "Projects", value: "\(store.projects.count)", detail: "\(store.openProjectCount) open")
            DetailStatCardView(title: "Tracked Time", value: store.totalDurationText, detail: "Across all projects")
            DetailStatCardView(title: "Today", value: store.todayDurationText, detail: "\(store.totalRecordCount) total records")
            DetailStatCardView(title: "Completed", value: "\(store.completedProjectCount)", detail: "Closed projects")
        }
    }
}
