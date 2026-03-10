import SwiftUI

struct ContentView: View {
    let viewModel: AppViewModel

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: Binding(get: { viewModel.selectedSection }, set: { viewModel.selectedSection = $0 })) { section in
                Label(section.rawValue, systemImage: section.symbol)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            Group {
                switch viewModel.selectedSection ?? .download {
                case .download:
                    DownloadView(viewModel: viewModel)
                case .send:
                    SendView(viewModel: viewModel)
                case .settings:
                    SettingsView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Limpar logs") {
                    viewModel.clearLogs()
                }
                .disabled(viewModel.logs.isEmpty)
            }
        }
    }
}

private struct DownloadView: View {
    let viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard(
                    title: "Download de XML por chave",
                    subtitle: "Cole ou importe chaves, ajuste credenciais e salve tudo diretamente nesta tela."
                )

                credentialsCard
                downloadCard
                StatusAndLogsView(viewModel: viewModel)
            }
            .padding(24)
        }
    }

    private var credentialsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Credenciais do Web Service")
                    .font(.headline)
                TextField("Usuário", text: Binding(get: { viewModel.usernameInput }, set: { viewModel.usernameInput = $0 }))
                    .textFieldStyle(.roundedBorder)
                SecureField("Senha", text: Binding(get: { viewModel.passwordInput }, set: { viewModel.passwordInput = $0 }))
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Salvar credenciais") { viewModel.saveCredentials() }
                        .buttonStyle(.borderedProminent)
                    Button("Limpar") { viewModel.clearCredentials() }
                }
                TextField("Endpoint de download", text: Binding(get: { viewModel.downloadURLInput }, set: { viewModel.downloadURLInput = $0 }), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                Button("Salvar endpoint") { viewModel.saveEndpoints() }
                    .buttonStyle(.bordered)
            }
        }
    }

    private var downloadCard: some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Pasta de saída", text: Binding(get: { viewModel.downloadDirectoryInput }, set: { viewModel.downloadDirectoryInput = $0 }))
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Escolher pasta") { viewModel.pickDownloadDirectory() }
                    Button("Salvar pasta") { viewModel.saveDirectories() }
                    Button("Importar chaves de arquivo") { viewModel.importKeysFromFile() }
                    Button("Limpar lista") { viewModel.downloadKeysText = "" }
                    Spacer()
                    Stepper("Concorrência: \(viewModel.settings.concurrencyLimit)", value: Binding(get: { viewModel.settings.concurrencyLimit }, set: { viewModel.settings.concurrencyLimit = $0 }), in: 1...20)
                        .frame(width: 220)
                }
                Text("Chaves de acesso")
                    .font(.headline)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(get: { viewModel.downloadKeysText }, set: { viewModel.downloadKeysText = $0 }))
                        .font(.body.monospaced())
                        .frame(minHeight: 240)
                        .padding(10)
                        .background(Color(nsColor: .textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    if viewModel.downloadKeysText.isEmpty {
                        Text("Cole uma chave por linha ou importe um arquivo .txt/.csv")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 18)
                            .padding(.leading, 16)
                            .allowsHitTesting(false)
                    }
                }
                HStack {
                    Text("\(viewModel.parsedKeys.count) chave(s) identificada(s)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        Task { await viewModel.downloadAll() }
                    } label: {
                        if viewModel.isDownloading {
                            ProgressView().controlSize(.small)
                        }
                        Text(viewModel.isDownloading ? "Baixando..." : "Baixar XMLs")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isDownloading || viewModel.parsedKeys.isEmpty)
                }
            }
        }
    }
}

private struct SendView: View {
    let viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard(
                    title: "Envio de XML para SAP",
                    subtitle: "Selecione a pasta, revise os XMLs encontrados e envie para NF-e ou CT-e."
                )

                credentialsCard
                sendCard
                filesCard
                StatusAndLogsView(viewModel: viewModel)
            }
            .padding(24)
        }
    }

    private var credentialsCard: some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Credenciais do Web Service")
                    .font(.headline)
                TextField("Usuário", text: Binding(get: { viewModel.usernameInput }, set: { viewModel.usernameInput = $0 }))
                    .textFieldStyle(.roundedBorder)
                SecureField("Senha", text: Binding(get: { viewModel.passwordInput }, set: { viewModel.passwordInput = $0 }))
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Salvar credenciais") { viewModel.saveCredentials() }
                        .buttonStyle(.borderedProminent)
                    Button("Limpar") { viewModel.clearCredentials() }
                }
            }
        }
    }

    private var sendCard: some View {
        card {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Tipo de serviço", selection: Binding(get: { viewModel.selectedServiceKind }, set: { viewModel.selectedServiceKind = $0 })) {
                    ForEach(ServiceKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Pasta de leitura", text: Binding(get: { viewModel.sendDirectoryInput }, set: { viewModel.sendDirectoryInput = $0 }))
                    .textFieldStyle(.roundedBorder)

                TextField(
                    viewModel.selectedServiceKind.endpointTitle,
                    text: Binding(
                        get: { viewModel.selectedServiceKind == .nfe ? viewModel.nfeSendURLInput : viewModel.cteSendURLInput },
                        set: {
                            if viewModel.selectedServiceKind == .nfe {
                                viewModel.nfeSendURLInput = $0
                            } else {
                                viewModel.cteSendURLInput = $0
                            }
                        }
                    ),
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

                Toggle("Apagar arquivos após envio com sucesso", isOn: Binding(get: { viewModel.settings.deleteSentFiles }, set: { viewModel.settings.deleteSentFiles = $0 }))

                HStack {
                    Button("Escolher pasta") { viewModel.pickSendDirectory() }
                    Button("Salvar configurações") {
                        viewModel.saveDirectories()
                        viewModel.saveEndpoints()
                    }
                    Spacer()
                    Button {
                        Task { await viewModel.sendAll() }
                    } label: {
                        if viewModel.isSending {
                            ProgressView().controlSize(.small)
                        }
                        Text(viewModel.isSending ? "Enviando..." : "Enviar XMLs")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSending || viewModel.sendableXMLFiles.isEmpty)
                }
            }
        }
    }

    private var filesCard: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Arquivos XML encontrados")
                    .font(.headline)
                if viewModel.sendableXMLFiles.isEmpty {
                    Text("Nenhum XML encontrado na pasta selecionada.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.sendableXMLFiles.prefix(20), id: \.path) { url in
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.blue)
                            Text(url.lastPathComponent)
                                .textSelection(.enabled)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    if viewModel.sendableXMLFiles.count > 20 {
                        Text("Mais \(viewModel.sendableXMLFiles.count - 20) arquivo(s) não exibidos.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    let viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard(
                    title: "Configurações",
                    subtitle: "Tela complementar para revisar tudo com calma."
                )

                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Credenciais")
                            .font(.headline)
                        TextField("Usuário", text: Binding(get: { viewModel.usernameInput }, set: { viewModel.usernameInput = $0 }))
                            .textFieldStyle(.roundedBorder)
                        SecureField("Senha", text: Binding(get: { viewModel.passwordInput }, set: { viewModel.passwordInput = $0 }))
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button("Salvar credenciais") { viewModel.saveCredentials() }
                                .buttonStyle(.borderedProminent)
                            Button("Limpar") { viewModel.clearCredentials() }
                        }
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Endpoints")
                            .font(.headline)
                        TextField("Download XML", text: Binding(get: { viewModel.downloadURLInput }, set: { viewModel.downloadURLInput = $0 }), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                        TextField("Envio NF-e", text: Binding(get: { viewModel.nfeSendURLInput }, set: { viewModel.nfeSendURLInput = $0 }), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                        TextField("Envio CT-e", text: Binding(get: { viewModel.cteSendURLInput }, set: { viewModel.cteSendURLInput = $0 }), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                        Button("Salvar endpoints") { viewModel.saveEndpoints() }
                            .buttonStyle(.borderedProminent)
                    }
                }

                card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pastas")
                            .font(.headline)
                        HStack {
                            TextField("Pasta de download", text: Binding(get: { viewModel.downloadDirectoryInput }, set: { viewModel.downloadDirectoryInput = $0 }))
                                .textFieldStyle(.roundedBorder)
                            Button("Escolher") { viewModel.pickDownloadDirectory() }
                        }
                        HStack {
                            TextField("Pasta de envio", text: Binding(get: { viewModel.sendDirectoryInput }, set: { viewModel.sendDirectoryInput = $0 }))
                                .textFieldStyle(.roundedBorder)
                            Button("Escolher") { viewModel.pickSendDirectory() }
                        }
                        Button("Salvar pastas") { viewModel.saveDirectories() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(24)
        }
    }
}

private struct StatusAndLogsView: View {
    let viewModel: AppViewModel

    var body: some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Status")
                    .font(.headline)
                Text(viewModel.lastSummary)
                    .foregroundStyle(.secondary)
                Divider()
                Text("Logs")
                    .font(.headline)
                if viewModel.logs.isEmpty {
                    Text("Nenhum log ainda.")
                        .foregroundStyle(.secondary)
                } else {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.logs) { log in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: log.level.symbol)
                                    .foregroundStyle(color(for: log.level))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(log.message)
                                    Text(log.timestamp.formatted(date: .numeric, time: .standard))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private func color(for level: OperationLog.Level) -> Color {
        switch level {
        case .info: .blue
        case .success: .green
        case .warning: .orange
        case .error: .red
        }
    }
}

private struct HeroCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
            Text(subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.20), Color.blue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    content()
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
}
