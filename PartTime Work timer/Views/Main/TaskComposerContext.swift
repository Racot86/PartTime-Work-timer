//
//  TaskComposerContext.swift
//  PartTime Work timer
//

import Foundation

struct TaskComposerContext: Identifiable {
    let projectID: UUID

    var id: UUID {
        projectID
    }
}
