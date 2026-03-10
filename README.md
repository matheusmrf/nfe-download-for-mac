# NFeDownloadForMAC

Aplicação macOS nativa em SwiftUI para substituir o utilitário legado `DownloadNFeArcelormittal` em Windows Forms.

## O que o app faz

- download de XML por chave de acesso via serviço SAP
- envio de XMLs locais para endpoints SAP de NF-e ou CT-e
- edição e persistência local de credenciais, endpoints e pastas
- seleção de pasta via interface nativa do macOS
- geração de `.app` por Xcode ou script local

## Abrir no Xcode

Abra:

- `NFeDownloadForMAC.xcodeproj`

ou, se preferir, o `Package.swift`.

## Gerar `.app`

### Pelo Xcode

1. Abra `NFeDownloadForMAC.xcodeproj`
2. Selecione o scheme `NFeDownloadForMacApp`
3. `Product > Run` para testar
4. `Product > Archive` para empacotar

### Pelo script

```bash
cd /Users/matheusfigueiredo/Documents/Arcelormittal/Desenvolvimentos/NFeDownloadForMAC
./scripts/build_app.sh
```

O app final será copiado para:

```text
dist/NFeDownloadForMacApp.app
```

## Fluxo de uso

### Download

- edite usuário e senha direto na tela
- salve as credenciais
- cole as chaves ou importe um `.txt/.csv`
- escolha a pasta de saída
- clique em `Baixar XMLs`

### Envio

- edite usuário e senha direto na tela
- escolha a pasta com XMLs
- selecione `NF-e` ou `CT-e`
- confira a lista de XMLs encontrados
- clique em `Enviar XMLs`

## Observações

- os valores padrão de endpoints vieram do sistema legado em C#
- a pasta `NFeDownloaderForMacOS/` foi mantida como referência histórica
- a interface agora usa campos locais com botão de salvar, para evitar o problema de edição/reset durante digitação
