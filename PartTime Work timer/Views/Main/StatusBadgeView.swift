//
//  StatusBadgeView.swift
//  PartTime Work timer
//

import SwiftUI

struct StatusBadgeView: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)

            Text(title)
                .foregroundStyle(.primary)
        }
        .font(.caption.weight(.medium))
        .imageScale(.small)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .glassEffect(.regular.tint(tint.opacity(0.16)), in: Capsule())
    }
}
