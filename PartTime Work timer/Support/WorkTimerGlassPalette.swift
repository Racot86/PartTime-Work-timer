//
//  WorkTimerGlassPalette.swift
//  PartTime Work timer
//

import SwiftUI

enum WorkTimerGlassPalette {
    static let neutralSurfaceTint = Color.primary.opacity(0.05)
    static let raisedSurfaceTint = Color.primary.opacity(0.07)
    static let accentSurfaceTint = Color.accentColor.opacity(0.16)
    static let runningSurfaceTint = Color.red.opacity(0.18)
    static let restSurfaceTint = Color.orange.opacity(0.18)
    static let completionSurfaceTint = Color.secondary.opacity(0.14)

    static let accentIcon = Color.accentColor.opacity(0.88)
    static let trackedIcon = Color.accentColor.opacity(0.72)
    static let runningIcon = Color.red.opacity(0.92)
    static let restIcon = Color.orange.opacity(0.9)
    static let completionIcon = Color.secondary
}
