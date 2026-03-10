import Foundation

struct XMLSenderService {
    func sendXML(at fileURL: URL, kind: ServiceKind, settings: AppSettings) async throws {
        let rawXML = try String(contentsOf: fileURL, encoding: .utf8)
        let sanitizedXML = rawXML.removingXMLDeclaration()
        let envelope = SOAPEnvelopeBuilder.sendEnvelope(xmlBody: sanitizedXML)

        guard let url = URL(string: settings.endpoint(for: kind)) else {
            throw NSError(domain: "NFeDownloadForMacApp", code: 1004, userInfo: [NSLocalizedDescriptionKey: "URL de envio inválida para \(kind.rawValue)."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 180
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(basicAuth(username: settings.username, password: settings.password), forHTTPHeaderField: "Authorization")
        request.httpBody = envelope.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "NFeDownloadForMacApp", code: 1005, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor."])
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "sem corpo"
            throw NSError(domain: "NFeDownloadForMacApp", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(body)"])
        }
    }

    private func basicAuth(username: String, password: String) -> String {
        let token = Data("\(username):\(password)".utf8).base64EncodedString()
        return "Basic \(token)"
    }
}

private extension String {
    func removingXMLDeclaration() -> String {
        let pattern = #"^\s*<\?xml[^>]*\?>\s*"#
        return replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}
