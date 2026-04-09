//
//  IconActionButton.swift
//  PartTime Work timer
//

import SwiftUI

struct IconActionButton: View {
    enum Prominence {
        case standard
        case prominent
    }

    let title: String
    let systemImage: String
    var prominence: Prominence = .standard
    var role: ButtonRole? = nil
    let action: () -> Void

    @ViewBuilder
    var body: some View {
        switch prominence {
        case .standard:
            baseButton
                .buttonStyle(.bordered)
        case .prominent:
            baseButton
                .buttonStyle(.borderedProminent)
        }
    }

    private var baseButton: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .frame(minWidth: 14)
        }
        .controlSize(.small)
        .help(title)
    }
}
