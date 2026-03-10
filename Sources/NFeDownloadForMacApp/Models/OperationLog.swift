import Foundation

struct OperationLog: Identifiable {
    enum Level {
        case info
        case success
        case warning
        case error

        var symbol: String {
            switch self {
            case .info:
                return "info.circle"
            case .success:
                return "checkmark.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            case .error:
                return "xmark.octagon.fill"
            }
        }
    }

    let id = UUID()
    let timestamp: Date
    let level: Level
    let message: String

    init(_ message: String, level: Level = .info, timestamp: Date = .now) {
        self.timestamp = timestamp
        self.level = level
        self.message = message
    }
}
