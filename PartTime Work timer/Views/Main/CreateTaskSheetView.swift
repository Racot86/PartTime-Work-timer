//
//  CreateTaskSheetView.swift
//  PartTime Work timer
//

import SwiftUI

struct CreateTaskSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var taskName = ""

    let projectName: String
    let onCreate: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("New Task")
                .font(.title3.weight(.semibold))

            Text("Project: \(projectName)")
                .foregroundStyle(.secondary)
                .font(.callout)

            TextField("Task name", text: $taskName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.glass)

                Button("Create") {
                    onCreate(taskName)
                    dismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
