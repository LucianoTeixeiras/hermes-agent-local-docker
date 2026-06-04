# Hermes Agent Local Docker Starter Kit

Starter kit para executar o Hermes Agent localmente via Docker, com foco em seguranca, reprodutibilidade e documentacao clara para times tecnicos e nao tecnicos.

O projeto empacota a abordagem recomendada pela documentacao oficial do Hermes: o container permanece stateless e todo o estado do agente fica persistido em `/opt/data`, mapeado localmente para `hermes-data/`.

## Principais recursos

- Gateway Hermes em Docker Compose.
- API OpenAI-compatible protegida por `API_SERVER_KEY`.
- Portas publicadas apenas em `127.0.0.1` por padrao.
- Volume local persistente para configuracoes, sessoes, memorias, skills e logs.
- Dashboard desabilitado por padrao para evitar exposicao acidental.
- Scripts PowerShell para bootstrap, start, stop e logs.
- Documentacao tecnica e executiva pronta para compartilhamento interno.

## Inicio rapido

Escolha o guia do seu ambiente:

- [Windows](docs/WINDOWS.md)
- [Linux, WSL e Ubuntu](docs/LINUX_WSL.md)

### Windows

1. Copie o arquivo de ambiente:

   ```powershell
   Copy-Item .env.example .env
   ```

2. Gere uma chave forte e atualize `API_SERVER_KEY` no arquivo `.env`.

   ```powershell
   -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Minimum 0 -Maximum 256) })
   ```

3. Execute o setup inicial. Ele grava configuracoes, credenciais e sessoes em `hermes-data/`.

   ```powershell
   .\scripts\windows\bootstrap.ps1
   ```

   Para usar o fluxo recomendado do Nous Portal:

   ```powershell
   .\scripts\windows\bootstrap.ps1 -Portal
   ```

4. Suba o gateway:

   ```powershell
   .\scripts\windows\start.ps1
   ```

5. Acompanhe logs:

   ```powershell
   .\scripts\windows\logs.ps1
   ```

### Linux, WSL e Ubuntu

1. Copie o arquivo de ambiente:

   ```bash
   cp .env.example .env
   ```

2. Gere uma chave forte e atualize `API_SERVER_KEY` no arquivo `.env`.

   ```bash
   openssl rand -hex 32
   ```

3. Execute o setup inicial:

   ```bash
   chmod +x scripts/linux/*.sh
   ./scripts/linux/bootstrap.sh
   ```

   Para usar o fluxo recomendado do Nous Portal:

   ```bash
   ./scripts/linux/bootstrap.sh --portal
   ```

4. Suba o gateway:

   ```bash
   ./scripts/linux/start.sh
   ```

5. Acompanhe logs:

   ```bash
   ./scripts/linux/logs.sh
   ```

## Endpoints locais

- API OpenAI-compatible e health endpoint: `http://127.0.0.1:8642`
- Dashboard, se habilitado: `http://127.0.0.1:9119`

## Seguranca por padrao

Este starter kit evita publicar o Hermes diretamente na rede. Antes de alterar `API_SERVER_BIND` ou `DASHBOARD_BIND` para `0.0.0.0`, configure firewall, TLS, autenticacao e reverse proxy.

Arquivos sensiveis nao devem ser versionados:

- `.env`
- `hermes-data/`
- backups de `hermes-data/`

O `.env.example` inclui variaveis opcionais para providers de modelos. Preencha somente as chaves que usar, por exemplo `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY` ou `OPENAI_API_KEY`. Os campos `*_BASE_URL` ja trazem defaults comuns quando ha endpoint estavel documentado.

## Documentacao

- [Documentacao tecnica](docs/TECNICA.md)
- [Documentacao executiva](docs/EXECUTIVA.md)
- [Guia Windows](docs/WINDOWS.md)
- [Guia Linux, WSL e Ubuntu](docs/LINUX_WSL.md)

## Exemplos

- [config.yaml.example](examples/config.yaml.example): exemplo de configuracao do Hermes com main model, aliases, fallback, modelos auxiliares e substituicao por variaveis do `.env`.

## Licenca

Distribuido sob a licenca Apache-2.0. Veja [LICENSE](LICENSE).
