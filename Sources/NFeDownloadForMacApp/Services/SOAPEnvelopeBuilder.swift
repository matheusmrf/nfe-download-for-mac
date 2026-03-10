import Foundation

enum SOAPEnvelopeBuilder {
    static func downloadEnvelope(for key: String) -> String {
        """
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <MT_DownloadXML_NFE_Request xmlns="urn:NFEAPPS:GRCNFE:DownloadXML">
              <NFEID>\(key.xmlEscaped)</NFEID>
            </MT_DownloadXML_NFE_Request>
          </soap:Body>
        </soap:Envelope>
        """
    }

    static func sendEnvelope(xmlBody: String) -> String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                          xmlns:nfe="http://www.portalfiscal.inf.br/nfe"
                          xmlns:xd="http://www.w3.org/2000/09/xmldsig#">
          <soapenv:Header/>
          <soapenv:Body>
            \(xmlBody)
          </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}

private extension String {
    var xmlEscaped: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
