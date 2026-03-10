# NFeDownloadForMAC

Repositório em estágio inicial para uma versão .NET do utilitário de download de NFe voltada a macOS. No estado atual, o projeto está mais próximo de um esqueleto/template do que de uma aplicação funcional completa.

## Situação atual do projeto

A análise do código mostra que o repositório contém:

- um projeto `net9.0` usando `Microsoft.NET.Sdk.Web`
- um `Program.cs` mínimo com endpoint `Hello World`
- vários arquivos herdados de uma possível versão anterior (`Form1.cs`, `ThreadsUtil.cs`, proxies de serviço), mas atualmente vazios
- arquivos `appsettings.json` e `launchSettings.json` padrão

Em resumo: o nome do projeto indica uma ferramenta de download de NFe para Mac, mas o código versionado hoje ainda não implementa essa funcionalidade.

## Estrutura

```text
NFeDownloadForMAC/
├── README.md
├── NFeDownloadForMAC.sln
└── NFeDownloaderForMacOS/
    ├── Program.cs
    ├── NFeDownloaderForMacOS.csproj
    ├── appsettings.json
    ├── appsettings.Development.json
    ├── Properties/
    │   └── launchSettings.json
    ├── Form1.cs                          # vazio
    ├── Form1Designer.cs                  # vazio
    ├── ThreadsUtil.cs                    # vazio
    ├── NFE_FB2B_OBService.cs             # vazio
    └── MI_LCORPNF00001_DownloadXML_OUTIN_NFE_Out_SynCompleted.cs  # vazio
```

## Stack atual

- .NET 9
- ASP.NET Core minimal API

## Como executar o estado atual

```bash
cd NFeDownloaderForMacOS
dotnet restore
dotnet run
```

Resultado esperado:

- a aplicação sobe um servidor web local
- o endpoint raiz `/` retorna `Hello World!`

## Pré-requisitos

- .NET SDK 9.0
- macOS, Linux ou Windows para rodar o template atual

## O que falta para virar a ferramenta prometida

- implementação da lógica de download de NFe
- integração com Web Service ou API de origem
- interface de usuário real
- configuração de credenciais e endpoints
- persistência de arquivos baixados
- tratamento de erros e logs

## Interpretação provável

Este repositório parece ser uma tentativa de migração ou recomeço do utilitário de download em uma stack mais nova, sem conclusão até o momento.

## Próximos passos recomendados

- decidir se o projeto será web, desktop ou CLI
- reaproveitar a lógica do projeto `DownloadNFeArcelormittal` se for o mesmo caso de uso
- remover arquivos vazios ou substituí-los por implementação real
- documentar a arquitetura alvo antes de continuar o desenvolvimento
