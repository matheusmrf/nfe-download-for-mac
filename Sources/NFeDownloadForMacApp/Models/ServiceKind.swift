import Foundation

enum ServiceKind: String, CaseIterable, Codable, Identifiable {
    case nfe = "NF-e"
    case cte = "CT-e"

    var id: String { rawValue }

    var endpointTitle: String {
        switch self {
        case .nfe:
            return "Endpoint de envio NF-e"
        case .cte:
            return "Endpoint de envio CT-e"
        }
    }
}
