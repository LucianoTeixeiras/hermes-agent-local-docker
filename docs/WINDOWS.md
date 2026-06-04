# Guia Windows - Hermes Agent Local Docker

## Requisitos

- Windows 10/11.
- Docker Desktop instalado e em execucao.
- PowerShell 5.1 ou PowerShell 7.
- Git, se for contribuir com o projeto.

## Setup inicial

Copie o template de ambiente:

```powershell
Copy-Item .env.example .env
```

Gere uma chave para `API_SERVER_KEY`:

```powershell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Minimum 0 -Maximum 256) })
```

Edite o arquivo `.env` e substitua `API_SERVER_KEY`.

Opcionalmente, configure no mesmo `.env` as chaves dos providers que serao usadas pelo Hermes, por exemplo:

```env
OPENROUTER_API_KEY=
ANTHROPIC_API_KEY=
GOOGLE_API_KEY=
OPENAI_API_KEY=
OPENAI_BASE_URL=https://api.openai.com/v1
```

Para configuracao permanente pelo proprio Hermes, use o setup interativo ou `hermes config set`, que grava segredos em `hermes-data/.env`.
Os campos `*_BASE_URL` do `.env.example` ja estao preenchidos com defaults comuns quando o provider tem endpoint estavel.

Execute o setup do Hermes:

```powershell
.\scripts\windows\bootstrap.ps1
```

Com Nous Portal:

```powershell
.\scripts\windows\bootstrap.ps1 -Portal
```

Opcionalmente, use o exemplo de configuracao:

```powershell
Copy-Item .\examples\config.yaml.example .\hermes-data\config.yaml
```

Depois ajuste `provider`, `default`, aliases e modelos auxiliares conforme seus providers.

## Operacao

Subir:

```powershell
.\scripts\windows\start.ps1
```

Logs:

```powershell
.\scripts\windows\logs.ps1
```

Parar:

```powershell
.\scripts\windows\stop.ps1
```

## Observacoes

- Os scripts na raiz de `scripts/` continuam funcionando como atalhos Windows.
- O volume persistente fica em `hermes-data/`.
- As portas sao publicadas apenas em `127.0.0.1` por padrao.
