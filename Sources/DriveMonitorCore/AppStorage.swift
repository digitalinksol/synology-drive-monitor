import Foundation

/// On-disk home for history, staging, and the undo cache. Lives outside CloudStorage.
public enum AppStorage {
    public static let folderName = "Unstuckerator"
    private static let legacyFolderName = "Synology Drive Monitor"

    /// The application-support folder. An existing folder from the previous name is moved once.
    public static func folderURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let current = base.appendingPathComponent(folderName, isDirectory: true)
        let legacy = base.appendingPathComponent(legacyFolderName, isDirectory: true)
        let files = FileManager.default
        if !files.fileExists(atPath: current.path), files.fileExists(atPath: legacy.path) {
            try files.moveItem(at: legacy, to: current)
        }
        return current
    }
}
