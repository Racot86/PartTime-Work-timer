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
        VStack(alignment: .leading, spacing: 18) {
            Text("New Task")
                .font(.title2.bold())

            Text("Project: \(projectName)")
                .foregroundStyle(.secondary)

            TextField("Task name", text: $taskName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Create") {
                    onCreate(taskName)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
