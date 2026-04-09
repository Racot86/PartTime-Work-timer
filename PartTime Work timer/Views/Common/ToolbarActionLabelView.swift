//
//  ToolbarActionLabelView.swift
//  PartTime Work timer
//

import SwiftUI

struct ToolbarActionLabelView: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .frame(minWidth: 14)
    }
}
