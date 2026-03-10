import Foundation

enum XMLResponseParser {
    static func extractEVString(from data: Data) throws -> String {
        let delegate = ValueCaptureParser(targetElement: "EV_STRING")
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        if parser.parse(), let value = delegate.value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            return value
        }

        if let parserError = parser.parserError {
            throw parserError
        }

        throw NSError(domain: "NFeDownloadForMacApp", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Resposta SOAP sem conteúdo EV_STRING."])
    }
}

private final class ValueCaptureParser: NSObject, XMLParserDelegate {
    private let targetElement: String
    private var currentElement: String?
    private var buffer = ""
    private(set) var value: String?

    init(targetElement: String) {
        self.targetElement = targetElement
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == targetElement {
            buffer = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard currentElement == targetElement else { return }
        buffer.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == targetElement {
            value = buffer
        }
        currentElement = nil
    }
}
