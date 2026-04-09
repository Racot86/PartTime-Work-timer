//
//  CreateProjectSheetView.swift
//  PartTime Work timer
//

import SwiftUI

struct CreateProjectSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var projectName = ""

    let onCreate: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("New Project")
                .font(.title3.weight(.semibold))

            TextField("Project name", text: $projectName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.glass)

                Button("Create") {
                    onCreate(projectName)
                    dismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
