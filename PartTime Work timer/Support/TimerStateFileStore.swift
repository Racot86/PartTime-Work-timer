//
//  TimerStateFileStore.swift
//  PartTime Work timer
//

import Foundation

struct TimerStateFileStore {
    private let fileManager: FileManager
    private let decoder: JSONDecoder

    let stateFileURL: URL

    init(
        fileManager: FileManager = .default,
        bundle: Bundle = .main,
        stateFileURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.stateFileURL = stateFileURL ?? Self.defaultStateFileURL(fileManager: fileManager, bundle: bundle)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadState() throws -> PersistedTimerState? {
        guard fileManager.fileExists(atPath: stateFileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: stateFileURL)
        return try decoder.decode(PersistedTimerState.self, from: data)
    }

    func deleteStateFileIfPresent() throws {
        guard fileManager.fileExists(atPath: stateFileURL.path) else { return }
        try fileManager.removeItem(at: stateFileURL)
    }

    private static func defaultStateFileURL(fileManager: FileManager, bundle: Bundle) -> URL {
        let appSupportURL = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.homeDirectoryForCurrentUser

        let appFolderName =
            bundle.bundleIdentifier ??
            (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
            "PartTime Work timer"

        return appSupportURL
            .appendingPathComponent(appFolderName, isDirectory: true)
            .appendingPathComponent("timer-state.json", isDirectory: false)
    }
}
