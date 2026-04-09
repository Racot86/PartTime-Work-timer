//
//  DetailStatCardView.swift
//  PartTime Work timer
//

import AppKit
import SwiftUI

struct DetailStatCardView: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Text(value)
                .font(.headline.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glassEffect(
            .regular.tint(WorkTimerGlassPalette.neutralSurfaceTint),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }
}
