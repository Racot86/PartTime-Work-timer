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
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .imageScale(.small)
            .foregroundStyle(tint)
    }
}
