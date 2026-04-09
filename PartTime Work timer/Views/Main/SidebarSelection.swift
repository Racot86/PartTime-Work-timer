//
//  SidebarSelection.swift
//  PartTime Work timer
//

import Foundation

enum SidebarSelection: Hashable {
    case project(UUID)
    case task(projectID: UUID, taskID: UUID)
}
