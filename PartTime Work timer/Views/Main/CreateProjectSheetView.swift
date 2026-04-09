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
        VStack(alignment: .leading, spacing: 18) {
            Text("New Project")
                .font(.title2.bold())

            Text("Create a project to group tasks and see total tracked time across them.")
                .foregroundStyle(.secondary)

            TextField("Project name", text: $projectName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Create") {
                    onCreate(projectName)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
