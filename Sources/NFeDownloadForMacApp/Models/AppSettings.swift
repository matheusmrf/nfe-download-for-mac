import Foundation

struct AppSettings: Codable {
    var username: String = "webservice"
    var password: String = "piservice"
    var downloadURL: String = "http://xp0abdb0.belgo.com.br:50200/XISOAPAdapter/MessageServlet?channel=:AM_APPS:Soap_Sender_DownloadXML_OUTIN_NFE&version=3.0&Sender.Service=AM_APPS&Interface=urn%3ANFEAPPS%3AGRCNFE%3ADownloadXML%5EMI_LCORPNF00001_DownloadXML_OUTIN_NFE_Out_Syn"
    var nfeSendURL: String = "http://xp0abdb0.belgo.com.br:50200/XISOAPAdapter/MessageServlet?channel=:BC_Inbound_NFe:SoapSender_EnviaXMLNFE_SSLNFE&version=3.0&Sender.Service=BC_Inbound_NFe&Interface=http%3A%2F%2Fsap.com%2Fxi%2FNFE%2F009%5ENFE_FB2B_OB"
    var cteSendURL: String = "http://xp0abdb0.belgo.com.br:50200/XISOAPAdapter/MessageServlet?channel=:BC_Inbound_NFe:SoapSender_EnviaXMLCTE_SSLNFE&version=3.0&Sender.Service=BC_Inbound_NFe&Interface=http://sap.com/xi/CTE/300^CTE57_FB2B_OB"
    var downloadDirectory: String = NSHomeDirectory() + "/Downloads/NFeXML"
    var sendDirectory: String = NSHomeDirectory() + "/Downloads/NFeXML"
    var concurrencyLimit: Int = 8
    var deleteSentFiles: Bool = true

    func endpoint(for kind: ServiceKind) -> String {
        switch kind {
        case .nfe:
            return nfeSendURL
        case .cte:
            return cteSendURL
        }
    }
}
