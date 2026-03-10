import Foundation

struct SAPDownloadService {
    func downloadXML(for key: String, settings: AppSettings) async throws -> String {
        guard let url = URL(string: settings.downloadURL) else {
            throw NSError(domain: "NFeDownloadForMacApp", code: 1002, userInfo: [NSLocalizedDescriptionKey: "URL de download inválida."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("http://sap.com/xi/WebService/soap1.1", forHTTPHeaderField: "SOAPAction")
        request.setValue(basicAuth(username: settings.username, password: settings.password), forHTTPHeaderField: "Authorization")
        request.httpBody = SOAPEnvelopeBuilder.downloadEnvelope(for: key).data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        return try XMLResponseParser.extractEVString(from: data)
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "NFeDownloadForMacApp", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor."])
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
