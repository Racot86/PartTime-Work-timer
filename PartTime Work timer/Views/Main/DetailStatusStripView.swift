//
//  DetailStatusStripView.swift
//  PartTime Work timer
//

import SwiftUI

struct DetailStatusItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
}

struct DetailStatusStripView: View {
    let items: [DetailStatusItem]
    var note: String? = nil
    var noteSystemImage: String? = nil
    var noteTint: Color = .secondary

    var body: some View {
        if !items.isEmpty || note != nil {
            VStack(alignment: .leading, spacing: 8) {
                if !items.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(items) { item in
                            StatusBadgeView(
                                title: item.title,
                                systemImage: item.systemImage,
                                tint: item.tint
                            )
                        }

                        Spacer(minLength: 0)
                    }
                }

                if let note, let noteSystemImage {
                    Label(note, systemImage: noteSystemImage)
                        .font(.caption)
                        .foregroundStyle(noteTint)
                }
            }
        }
    }
}
