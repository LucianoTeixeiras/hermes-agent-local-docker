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

## Artefatos

- `Dockerfile`: imagem derivada minima baseada em `nousresearch/hermes-agent`.
- `docker-compose.yml`: servico persistente com gateway, limites de recursos, logging rotacionado e bind local.
- `.env.example`: template de variaveis para Compose.
- `scripts/bootstrap.ps1`: cria `.env`, cria `hermes-data/` e executa o wizard de setup.
- `scripts/start.ps1`: build e start do servico.
- `scripts/stop.ps1`: parada limpa.
- `scripts/logs.ps1`: acompanhamento de logs.

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
.\scripts\bootstrap.ps1
```

O setup cria os arquivos internos em `hermes-data/`. Chaves de provedores, tokens de bots e segredos do Hermes ficam no arquivo `hermes-data/.env`, nao no `.env` do Compose.

## Execucao

```powershell
.\scripts\start.ps1
```

Ver status:

```powershell
docker compose ps
```

Logs:

```powershell
.\scripts\logs.ps1
```

Parar:

```powershell
.\scripts\stop.ps1
```

## Gateway API

O Compose habilita a API com:

```yaml
API_SERVER_ENABLED: true
API_SERVER_HOST: 0.0.0.0
API_SERVER_KEY: ${API_SERVER_KEY}
```

Mesmo com host interno `0.0.0.0`, a porta publicada fica presa ao host `127.0.0.1`, evitando exposicao direta na rede. Para expor fora da maquina local, altere `API_SERVER_BIND` conscientemente e coloque autenticao/reverse proxy na frente.

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

- segredos em `hermes-data/.env`;
- configuracoes nao secretas em `hermes-data/config.yaml`;
- valores passados por variavel de ambiente no Compose sobrescrevem o `.env` interno quando usados diretamente.

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
