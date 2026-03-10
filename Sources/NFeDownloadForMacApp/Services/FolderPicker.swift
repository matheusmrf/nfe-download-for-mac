import AppKit
import Foundation

enum FolderPicker {
    @MainActor
    static func pickDirectory(startingAt path: String?) -> String? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Selecionar"
        panel.message = "Escolha a pasta que será usada na operação."

        if let path, !path.isEmpty {
            panel.directoryURL = URL(fileURLWithPath: path, isDirectory: true)
        }

        return panel.runModal() == .OK ? panel.url?.path : nil
    }
}
