import Foundation
import Observation

@Observable
final class SettingsStore {
    private let fileURL: URL
    var settings: AppSettings {
        didSet {
            save()
        }
    }

    init() {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("NFeDownloadForMacApp", isDirectory: true)
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        fileURL = baseDirectory.appendingPathComponent("settings.json")

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = AppSettings()
            save()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            NSLog("Falha ao salvar configurações: \(error.localizedDescription)")
        }
    }
}
