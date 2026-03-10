import Foundation
import Observation

@MainActor
@Observable
final class AppViewModel {
    var settingsStore: SettingsStore
    var selectedSection: AppSection? = .download
    var downloadKeysText = ""
    var selectedServiceKind: ServiceKind = .nfe
    var logs: [OperationLog] = []
    var isDownloading = false
    var isSending = false
    var lastSummary = "Configure os campos e execute uma operação."

    private let downloadService = SAPDownloadService()
    private let senderService = XMLSenderService()

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
    }

    var settings: AppSettings {
        get { settingsStore.settings }
        set { settingsStore.settings = newValue }
    }

    var parsedKeys: [String] {
        downloadKeysText
            .components(separatedBy: CharacterSet(charactersIn: ",\n\r\t ;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var sendDirectoryURL: URL {
        URL(fileURLWithPath: settings.sendDirectory, isDirectory: true)
    }

    var sendableXMLFiles: [URL] {
        guard FileManager.default.fileExists(atPath: sendDirectoryURL.path) else {
            return []
        }

        return (try? FileManager.default.contentsOfDirectory(at: sendDirectoryURL, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension.lowercased() == "xml" }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending } ?? []
    }

    func pickDownloadDirectory() {
        if let path = FolderPicker.pickDirectory(startingAt: settings.downloadDirectory) {
            settings.downloadDirectory = path
            appendLog("Pasta de download definida para \(path)", level: .info)
        }
    }

    func pickSendDirectory() {
        if let path = FolderPicker.pickDirectory(startingAt: settings.sendDirectory) {
            settings.sendDirectory = path
            appendLog("Pasta de envio definida para \(path)", level: .info)
        }
    }

    func updateUsername(_ value: String) {
        settings.username = value
    }

    func updatePassword(_ value: String) {
        settings.password = value
    }

    func updateDownloadURL(_ value: String) {
        settings.downloadURL = value
    }

    func updateNFESendURL(_ value: String) {
        settings.nfeSendURL = value
    }

    func updateCTESendURL(_ value: String) {
        settings.cteSendURL = value
    }

    func updateDownloadDirectory(_ value: String) {
        settings.downloadDirectory = value
    }

    func updateSendDirectory(_ value: String) {
        settings.sendDirectory = value
    }

    func appendDownloadKeys(from content: String) {
        let cleaned = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return }

        if downloadKeysText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            downloadKeysText = cleaned
        } else {
            downloadKeysText += "\n" + cleaned
        }

        appendLog("Chaves importadas para a área de download.", level: .info)
    }

    func importKeysFromFile() {
        guard let url = FolderPicker.pickTextFile() else { return }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            appendDownloadKeys(from: content)
        } catch {
            appendLog("Falha ao importar arquivo de chaves: \(error.localizedDescription)", level: .error)
        }
    }

    func clearLogs() {
        logs.removeAll()
        lastSummary = "Logs limpos."
    }

    func downloadAll() async {
        let keys = parsedKeys
        guard !keys.isEmpty else {
            appendLog("Informe ao menos uma chave para iniciar o download.", level: .warning)
            return
        }

        let outputDirectory = URL(fileURLWithPath: settings.downloadDirectory, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            appendLog("Não foi possível criar a pasta de download: \(error.localizedDescription)", level: .error)
            return
        }

        isDownloading = true
        lastSummary = "Executando download de \(keys.count) chave(s)..."
        appendLog("Iniciando download de \(keys.count) chave(s).", level: .info)

        let semaphore = AsyncSemaphore(limit: max(1, settings.concurrencyLimit))
        let stats = DownloadStats()
        let currentSettings = settings
        let service = downloadService

        await withTaskGroup(of: Void.self) { group in
            for key in keys {
                group.addTask {
                    await semaphore.withPermit {
                        do {
                            let xml = try await service.downloadXML(for: key, settings: currentSettings)
                            let safeFilename = key.replacingOccurrences(of: "/", with: "-") + ".xml"
                            let fileURL = outputDirectory.appendingPathComponent(safeFilename)
                            try xml.write(to: fileURL, atomically: true, encoding: .utf8)
                            await stats.incrementSuccess()
                            await MainActor.run {
                                self.appendLog("XML salvo para a chave \(key).", level: .success)
                            }
                        } catch {
                            await stats.incrementFailure()
                            await MainActor.run {
                                self.appendLog("Falha ao baixar \(key): \(error.localizedDescription)", level: .error)
                            }
                        }
                    }
                }
            }
            await group.waitForAll()
        }

        let result = await stats.snapshot()
        isDownloading = false
        lastSummary = "Download concluído: \(result.success) sucesso(s), \(result.failure) falha(s)."
        appendLog(lastSummary, level: result.failure == 0 ? .success : .warning)
    }

    func sendAll() async {
        let xmlFiles = sendableXMLFiles
        let fileManager = FileManager.default

        guard !xmlFiles.isEmpty else {
            appendLog("Nenhum arquivo XML encontrado em \(sendDirectoryURL.path).", level: .warning)
            return
        }

        isSending = true
        lastSummary = "Enviando \(xmlFiles.count) arquivo(s) como \(selectedServiceKind.rawValue)..."
        appendLog(lastSummary, level: .info)

        var successCount = 0
        var failureCount = 0

        for fileURL in xmlFiles {
            do {
                try await senderService.sendXML(at: fileURL, kind: selectedServiceKind, settings: settings)
                if settings.deleteSentFiles {
                    try? fileManager.removeItem(at: fileURL)
                }
                successCount += 1
                appendLog("Arquivo enviado: \(fileURL.lastPathComponent)", level: .success)
            } catch {
                failureCount += 1
                appendLog("Falha ao enviar \(fileURL.lastPathComponent): \(error.localizedDescription)", level: .error)
            }
        }

        isSending = false
        lastSummary = "Envio concluído: \(successCount) sucesso(s), \(failureCount) falha(s)."
        appendLog(lastSummary, level: failureCount == 0 ? .success : .warning)
    }

    private func appendLog(_ message: String, level: OperationLog.Level) {
        logs.insert(OperationLog(message, level: level), at: 0)
    }
}

actor AsyncSemaphore {
    private let limit: Int
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) {
        self.limit = limit
        self.count = limit
    }

    func withPermit(_ operation: () async -> Void) async {
        await wait()
        await operation()
        signal()
    }

    private func wait() async {
        if count > 0 {
            count -= 1
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    private func signal() {
        if let waiter = waiters.first {
            waiters.removeFirst()
            waiter.resume()
        } else {
            count = min(count + 1, limit)
        }
    }
}

actor DownloadStats {
    private var success = 0
    private var failure = 0

    func incrementSuccess() {
        success += 1
    }

    func incrementFailure() {
        failure += 1
    }

    func snapshot() -> (success: Int, failure: Int) {
        (success, failure)
    }
}
