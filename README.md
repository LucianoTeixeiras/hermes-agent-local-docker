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
   .\scripts\bootstrap.ps1
   ```

   Para usar o fluxo recomendado do Nous Portal:

   ```powershell
   .\scripts\bootstrap.ps1 -Portal
   ```

4. Suba o gateway:

   ```powershell
   .\scripts\start.ps1
   ```

5. Acompanhe logs:

   ```powershell
   .\scripts\logs.ps1
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

## Documentacao

- [Documentacao tecnica](docs/TECNICA.md)
- [Documentacao executiva](docs/EXECUTIVA.md)

## Licenca

Distribuido sob a licenca Apache-2.0. Veja [LICENSE](LICENSE).
