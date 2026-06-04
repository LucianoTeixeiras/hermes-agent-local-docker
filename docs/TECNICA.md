# Documentacao Tecnica - Hermes Agent Local Docker

## Objetivo

Executar o Hermes Agent localmente dentro de um container Docker, mantendo configuracoes, chaves, sessoes, memorias, skills e logs em um diretorio persistente do projeto. A exposicao de rede fica restrita a `127.0.0.1` por padrao.

## Fontes oficiais usadas

- Docker: https://hermes-agent.nousresearch.com/docs/user-guide/docker
- Configuracao: https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- Seguranca: https://hermes-agent.nousresearch.com/docs/user-guide/security
- Modelos: https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models

## Arquitetura

```text
Host Windows
  Local-Docker/
    docker-compose.yml
    Dockerfile
    .env                  # variaveis do Compose; nao versionar
    hermes-data/          # volume persistente; nao versionar
      .env                # chaves e tokens criados pelo setup do Hermes
      config.yaml         # configuracao nao secreta
      SOUL.md             # identidade/persona do agente
      sessions/           # historico de conversas
      memories/           # memoria persistente
      skills/             # skills instaladas
      home/               # HOME usado por subprocessos e CLIs
      cron/ hooks/ logs/  # jobs, hooks e logs
```

O container usa `/opt/data` como fonte unica de estado, conforme a documentacao oficial. A imagem pode ser recriada ou atualizada sem perder dados, desde que `hermes-data/` seja preservado.

## Locais de trabalho recomendados

- Espelho/backup do repositorio: OneDrive ou outra ferramenta de sincronizacao.
- Execucao Docker no Windows: pasta local fora de sincronizacao, por exemplo `D:\00-agents2ai-agents\hermes-agent-local-docker`.
- Execucao Docker em WSL/Linux: filesystem Linux, por exemplo `~/projects/hermes-agent-local-docker`.

Evite usar a mesma pasta sincronizada para runtime Docker persistente. Isso reduz risco de conflito de permissao, lock de arquivo, lentidao de I/O e sincronizacao de dados sensiveis.

## Artefatos

- `Dockerfile`: imagem derivada minima baseada em `nousresearch/hermes-agent`.
- `docker-compose.yml`: servico persistente com gateway, limites de recursos, logging rotacionado e bind local.
- `docker-compose.volume.yml`: override opcional para usar volume Docker gerenciado em vez de bind mount local.
- `.env.example`: template de variaveis para Compose e chaves opcionais de providers.
- `scripts/windows/*.ps1`: operacao no Windows via PowerShell.
- `scripts/linux/*.sh`: operacao no Linux, WSL e Ubuntu via Bash.
- `scripts/*.ps1`: atalhos legados para os scripts Windows.

## Configuracao inicial

```powershell
Copy-Item .env.example .env
```

Gere uma chave para a API:

```powershell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Minimum 0 -Maximum 256) })
```

Atualize `API_SERVER_KEY` no `.env`. Em seguida:

```powershell
.\scripts\windows\bootstrap.ps1
```

Linux, WSL ou Ubuntu:

```bash
cp .env.example .env
openssl rand -hex 32
chmod +x scripts/linux/*.sh
./scripts/linux/bootstrap.sh
```

Em WSL sobre `/mnt/<drive>` ou filesystem Windows, prefira volume gerenciado pelo Docker:

```bash
./scripts/linux/bootstrap.sh --volume
./scripts/linux/start.sh --volume
```

Os scripts Linux detectam automaticamente WSL em `/mnt/<drive>/...` e usam `volume`, a menos que `--bind` ou `HERMES_DATA_MODE=bind` seja informado explicitamente.

O setup cria os arquivos internos em `hermes-data/`. Pela documentacao oficial, chaves de provedores, tokens de bots e segredos do Hermes pertencem ao arquivo `hermes-data/.env`.

Este projeto tambem aceita chaves de providers no `.env` da raiz para facilitar Docker Compose. O Compose carrega esse arquivo com `env_file`, entao variaveis como `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY` ou `OPENAI_BASE_URL` ficam disponiveis dentro do container. Para ambientes persistentes, prefira registrar esses valores pelo setup do Hermes ou por `hermes config set`, que salva segredos no local nativo do Hermes.

## Execucao

```powershell
.\scripts\windows\start.ps1
```

Linux, WSL ou Ubuntu:

```bash
./scripts/linux/start.sh
```

Ver status:

```powershell
docker compose ps
```

Logs:

```powershell
.\scripts\windows\logs.ps1
```

Linux, WSL ou Ubuntu:

```bash
./scripts/linux/logs.sh
```

Parar:

```powershell
.\scripts\windows\stop.ps1
```

Linux, WSL ou Ubuntu:

```bash
./scripts/linux/stop.sh
```

## Gateway API

O Compose habilita a API com:

```yaml
API_SERVER_ENABLED: true
API_SERVER_HOST: 0.0.0.0
API_SERVER_KEY: ${API_SERVER_KEY}
```

Mesmo com host interno `0.0.0.0`, a porta publicada fica presa ao host `127.0.0.1`, evitando exposicao direta na rede. Para expor fora da maquina local, altere `API_SERVER_BIND` conscientemente e coloque autenticao/reverse proxy na frente.

`API_SERVER_KEY` protege a API HTTP/OpenAI-compatible. Ela nao substitui as allowlists do gateway para plataformas de mensageria. Se o log mostrar `No user allowlists configured`, configure:

```env
GATEWAY_ALLOW_ALL_USERS=true
```

apenas para teste local, ou prefira allowlists explicitas:

```env
GATEWAY_ALLOWED_USERS=
TELEGRAM_ALLOWED_USERS=
DISCORD_ALLOWED_USERS=
SLACK_ALLOWED_USERS=
GOOGLE_CHAT_ALLOWED_USERS=
```

Em producao, mantenha `GATEWAY_ALLOW_ALL_USERS=false`.

## Dashboard

O dashboard fica desabilitado por padrao:

```env
HERMES_DASHBOARD=0
```

Para habilitar de forma segura, configure:

```env
HERMES_DASHBOARD=1
HERMES_DASHBOARD_OAUTH_CLIENT_ID=<client-id>
```

Evite `HERMES_DASHBOARD_INSECURE=1`. A propria documentacao alerta que esse modo pode expor chaves de API e dados de sessao para qualquer pessoa com acesso a porta publicada.

## Modelos e provedores

Use o wizard:

```powershell
docker run -it --rm -v "${PWD}\hermes-data:/opt/data" nousresearch/hermes-agent setup
```

Ou ajuste dentro do container:

```powershell
docker compose exec hermes hermes config
docker compose exec hermes hermes config edit
docker compose exec hermes hermes config set model <provider/model>
```

A regra recomendada e:

- segredos persistentes do Hermes em `hermes-data/.env`;
- segredos temporarios ou de bootstrap tambem podem entrar no `.env` da raiz, pois o Compose repassa o arquivo ao container;
- configuracoes nao secretas em `hermes-data/config.yaml`;
- valores passados por variavel de ambiente no Compose sobrescrevem o `.env` interno quando usados diretamente.

Exemplos de variaveis de provider aceitas:

```env
OPENROUTER_API_KEY=
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
ANTHROPIC_API_KEY=
GOOGLE_API_KEY=
GEMINI_API_KEY=
OPENAI_API_KEY=
OPENAI_BASE_URL=https://api.openai.com/v1
DEEPSEEK_API_KEY=
DEEPSEEK_BASE_URL=https://api.deepseek.com
XAI_API_KEY=
XAI_BASE_URL=https://api.x.ai/v1
HF_TOKEN=
HF_BASE_URL=https://router.huggingface.co/v1
AWS_REGION=
AWS_PROFILE=
AZURE_FOUNDRY_API_KEY=
```

O `.env.example` ja preenche os `*_BASE_URL` com valores padrao quando a documentacao do Hermes ou do provider publica um endpoint estavel. Altere esses valores apenas quando usar proxy corporativo, gateway local, regioes especificas, self-hosting ou endpoints compativeis como LiteLLM, VLLM, SGLang, LM Studio, LocalAI ou Open WebUI.

## Exemplo de config.yaml

O arquivo [examples/config.yaml.example](../examples/config.yaml.example) traz uma base segura para `hermes-data/config.yaml`, incluindo:

- `model`: provider e modelo principal.
- `model_aliases`: aliases curtos para troca via `/model`.
- `fallback_providers`: modelos alternativos em caso de falha.
- `auxiliary`: modelos para tarefas auxiliares como vision, web extract e compression.
- `delegation`: configuracao de subagentes.
- `providers`: timeouts globais e por modelo.
- substituicao `${VAR_NAME}` para valores vindos do `.env`.

Fluxo recomendado:

Windows:

```powershell
Copy-Item .\examples\config.yaml.example .\hermes-data\config.yaml
```

Linux, WSL ou Ubuntu:

```bash
cp examples/config.yaml.example hermes-data/config.yaml
```

Depois ajuste `provider`, `default` e os modelos auxiliares conforme suas chaves disponiveis. Reinicie o gateway para novas sessoes carregarem a configuracao.

## Seguranca

Controles aplicados neste projeto:

- Portas publicadas apenas em `127.0.0.1`.
- `API_SERVER_KEY` obrigatoria no Compose.
- Dados persistentes e segredos fora do Git.
- Rotacao de logs Docker com `max-size` e `max-file`.
- Limites de CPU e memoria configuraveis.
- Um unico container usa um unico volume persistente.

Boas praticas operacionais:

- Nunca execute dois containers Hermes usando o mesmo `hermes-data/` ao mesmo tempo.
- Nao publique `8642` ou `9119` na internet sem proxy, TLS, autenticacao e regras de firewall.
- Faca backup criptografado de `hermes-data/`.
- Revise periodicamente `hermes-data/logs/` e `docker compose logs`.
- Mantenha `HERMES_IMAGE_TAG` pinado em ambientes controlados, por exemplo uma versao especifica em vez de `latest`.

## Backup e restore

Backup:

```powershell
Compress-Archive -Path .\hermes-data -DestinationPath .\backup-hermes-data.zip
```

Restore:

```powershell
Expand-Archive .\backup-hermes-data.zip -DestinationPath .
```

Pare o container antes de backup ou restore para evitar arquivos em escrita.

## Atualizacao

```powershell
docker compose pull
docker compose build --pull
docker compose up -d
```

Como a imagem e stateless e o estado fica em `/opt/data`, a atualizacao tende a preservar configuracao e sessoes.

## Operacao multi-profile

O Hermes suporta multiplos perfis dentro do mesmo container. A documentacao recomenda um container com varios perfis para a maioria dos casos.

```powershell
docker compose exec hermes hermes profile create coder
docker compose exec hermes hermes -p coder gateway start
docker compose exec hermes hermes -p coder gateway status
docker compose exec hermes hermes -p coder gateway stop
```

Use containers separados apenas quando precisar de isolamento forte por cliente, workload, rede, imagem ou limite de recurso.
