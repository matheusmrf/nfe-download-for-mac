import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case download = "Download"
    case send = "Envio"
    case settings = "Configurações"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .download:
            return "arrow.down.doc"
        case .send:
            return "paperplane"
        case .settings:
            return "slider.horizontal.3"
        }
    }
}
