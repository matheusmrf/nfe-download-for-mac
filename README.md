# NFeDownloadForMAC

Aplicação macOS nativa em SwiftUI para substituir o utilitário legado `DownloadNFeArcelormittal` em Windows Forms. O app oferece duas operações principais:

- download de XML por chave de acesso via serviço SAP
- envio de XMLs locais para endpoints SAP de NF-e ou CT-e

## O que foi feito

A pasta agora contém uma implementação nova em Swift, pensada para macOS:

- interface SwiftUI com visual nativo do macOS
- persistência automática de configurações no `Application Support`
- seleção de pastas por `NSOpenPanel`
- execução assíncrona com concorrência controlada no download
- logs de execução na própria interface
- suporte a envio para NF-e e CT-e

## Estrutura nova

```text
NFeDownloadForMAC/
├── Package.swift
├── README.md
├── Sources/
│   └── NFeDownloadForMacApp/
│       ├── NFeDownloadForMacApp.swift
│       ├── Models/
│       ├── Services/
│       ├── ViewModels/
│       └── Views/
└── NFeDownloaderForMacOS/   # projeto antigo em C#, mantido como referência
```

## Requisitos

- macOS 14 ou superior
- Swift 6
- Xcode para abrir a interface visualmente

## Como abrir no Xcode

1. Abra o Xcode.
2. Escolha `Open...`.
3. Selecione a pasta `NFeDownloadForMAC` ou o arquivo `Package.swift`.
4. Rode o target `NFeDownloadForMacApp`.

## Como compilar no terminal

```bash
cd /Users/matheusfigueiredo/Documents/Arcelormittal/Desenvolvimentos/NFeDownloadForMAC
swift build
swift run
```

## Configuração inicial

Na aba `Configurações`, ajuste:

- usuário
- senha
- endpoint de download
- endpoint de envio NF-e
- endpoint de envio CT-e
- pasta padrão de download
- pasta padrão de envio

Os valores atuais foram trazidos do utilitário original em C# como ponto de partida.

## Fluxos disponíveis

### Download

- cole as chaves de acesso no editor de texto
- escolha a pasta de saída
- ajuste o nível de concorrência
- clique em `Baixar XMLs`

### Envio

- escolha a pasta com XMLs
- selecione `NF-e` ou `CT-e`
- clique em `Enviar XMLs`
- opcionalmente, apague arquivos após sucesso

## Observações importantes

- o app depende do acesso de rede aos endpoints SAP internos
- os endpoints atuais usam HTTP e autenticação básica, conforme o sistema legado
- se o Web Service devolver um formato SOAP diferente do esperado, a extração do `EV_STRING` pode precisar de ajuste fino
- o projeto antigo em C# foi mantido na pasta apenas como referência funcional
