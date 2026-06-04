# Primeiro Contato via Docker

Este guia mostra como validar e interagir com o Hermes Agent depois que o container estiver rodando.

## Pre-requisitos

- Container `hermes-agent-local` em execucao.
- `API_SERVER_KEY` configurada no `.env`.
- Porta local `8642` publicada.

Em WSL/Linux usando volume:

```bash
./scripts/linux/start.sh --volume
```

Windows PowerShell:

```powershell
.\scripts\windows\start.ps1
```

## 1. Health check

WSL/Linux:

```bash
curl http://127.0.0.1:8642/health
```

Windows PowerShell:

```powershell
Invoke-RestMethod http://127.0.0.1:8642/health
```

Resposta esperada:

```json
{"status":"ok"}
```

Tambem existe o endpoint compativel com clientes OpenAI:

```bash
curl http://127.0.0.1:8642/v1/health
```

## 2. Definir a chave da API no terminal

Use a mesma chave configurada em `API_SERVER_KEY` no `.env`.

WSL/Linux:

```bash
export HERMES_API_KEY='sua_api_server_key'
```

Windows PowerShell:

```powershell
$env:HERMES_API_KEY='sua_api_server_key'
```

## 3. Listar modelos expostos

WSL/Linux:

```bash
curl http://127.0.0.1:8642/v1/models \
  -H "Authorization: Bearer $HERMES_API_KEY"
```

Windows PowerShell:

```powershell
Invoke-RestMethod `
  -Uri http://127.0.0.1:8642/v1/models `
  -Headers @{ Authorization = "Bearer $env:HERMES_API_KEY" }
```

O modelo padrao geralmente aparece como:

```text
hermes-agent
```

## 4. Primeira conversa com Chat Completions

WSL/Linux:

```bash
curl http://127.0.0.1:8642/v1/chat/completions \
  -H "Authorization: Bearer $HERMES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "hermes-agent",
    "messages": [
      {
        "role": "user",
        "content": "Ola Hermes. Responda em portugues, em uma frase, confirmando que voce esta operacional."
      }
    ]
  }'
```

Windows PowerShell:

```powershell
$body = @{
  model = "hermes-agent"
  messages = @(
    @{
      role = "user"
      content = "Ola Hermes. Responda em portugues, em uma frase, confirmando que voce esta operacional."
    }
  )
} | ConvertTo-Json -Depth 5

Invoke-RestMethod `
  -Uri http://127.0.0.1:8642/v1/chat/completions `
  -Method Post `
  -Headers @{
    Authorization = "Bearer $env:HERMES_API_KEY"
    "Content-Type" = "application/json"
  } `
  -Body $body
```

## 5. Primeira conversa com Responses API

Use a Responses API quando quiser conversas com estado, continuidade por `previous_response_id` ou integracao com clientes que ja usam esse formato.

WSL/Linux:

```bash
curl http://127.0.0.1:8642/v1/responses \
  -H "Authorization: Bearer $HERMES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "hermes-agent",
    "input": "Ola Hermes. Qual e o seu papel neste ambiente local?",
    "store": true
  }'
```

Windows PowerShell:

```powershell
$body = @{
  model = "hermes-agent"
  input = "Ola Hermes. Qual e o seu papel neste ambiente local?"
  store = $true
} | ConvertTo-Json -Depth 5

Invoke-RestMethod `
  -Uri http://127.0.0.1:8642/v1/responses `
  -Method Post `
  -Headers @{
    Authorization = "Bearer $env:HERMES_API_KEY"
    "Content-Type" = "application/json"
  } `
  -Body $body
```

## 6. Acompanhar logs

WSL/Linux com volume:

```bash
./scripts/linux/logs.sh --volume
```

Windows PowerShell:

```powershell
.\scripts\windows\logs.ps1
```

## 7. Proximos passos

- Configure Telegram: [Guia Telegram](../integrations/TELEGRAM.md).
- Configure modelos e providers: [Arquitetura e configuracao tecnica](../technical/ARCHITECTURE.md).
- Resolva erros comuns: [Troubleshooting](TROUBLESHOOTING.md).

## Referencia oficial

- API Server: https://hermes-agent.nousresearch.com/docs/user-guide/features/api-server/
