//
//  WorkspaceOverviewView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct WorkspaceOverviewView: View {
    @EnvironmentObject private var store: TimerStore

    let onCreateProject: () -> Void

    private let statColumns = [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                statsGrid
            }
            .padding(18)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Project Tracker")
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text("Create a project, add tasks, and log multiple time entries per task.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                IconActionButton(
                    title: "New Project",
                    systemImage: "plus",
                    prominence: .prominent,
                    action: onCreateProject
                )
            }

            if store.isRunning {
                HStack(spacing: 6) {
                    Image(systemName: "record.circle.fill")
                        .foregroundStyle(.red)
                        .imageScale(.small)

                    Text("Active: \(store.activeContextTitle) • \(store.activeClockText)")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor))
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var statsGrid: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            DetailStatCardView(title: "Projects", value: "\(store.projects.count)", detail: "\(store.openProjectCount) open")
            DetailStatCardView(title: "Tracked Time", value: store.totalDurationText, detail: "Across all projects")
            DetailStatCardView(title: "Today", value: store.todayDurationText, detail: "\(store.totalRecordCount) total records")
            DetailStatCardView(title: "Completed", value: "\(store.completedProjectCount)", detail: "Closed projects")
        }
    }
}
