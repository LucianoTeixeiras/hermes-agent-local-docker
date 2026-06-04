# Troubleshooting

## `s6-log: fatal: unable to fd_chmod ... Operation not permitted`

Sintoma:

```text
s6-log: fatal: unable to fd_chmod /opt/data/logs/gateways/default/current: Operation not permitted
```

Causa comum:

O Hermes esta escrevendo logs em `/opt/data`, mas `/opt/data` foi montado a partir de filesystem Windows/NTFS, pasta sincronizada ou `/mnt/<drive>` no WSL. Esse tipo de bind mount pode nao suportar todas as operacoes de permissao usadas pelo `s6-log`.

Solucao recomendada no WSL:

```bash
./scripts/linux/bootstrap.sh --volume
./scripts/linux/start.sh --volume
```

Se o projeto estiver em `/mnt/c/...`, `/mnt/d/...` ou outro drive montado no WSL, os scripts Linux atuais escolhem `volume` automaticamente. O parametro `--volume` continua disponivel para deixar a intencao explicita.

Com Nous Portal:

```bash
./scripts/linux/bootstrap.sh --portal --volume
./scripts/linux/start.sh --volume
```

Alternativa:

Clone o repositorio dentro do filesystem Linux do WSL, por exemplo:

```bash
~/projects/hermes-agent-local-docker
```

Depois use o modo padrao com bind mount:

```bash
./scripts/linux/bootstrap.sh
./scripts/linux/start.sh
```

## Ver dados no volume gerenciado pelo Docker

Quando usar `--volume`, os dados ficam no volume `hermes-agent-data`.

Listar:

```bash
docker volume ls | grep hermes-agent-data
```

Inspecionar:

```bash
docker volume inspect hermes-agent-data
```

Abrir um shell temporario com o volume montado:

```bash
docker run -it --rm -v hermes-agent-data:/opt/data alpine sh
```

Copiar o exemplo de configuracao para dentro do volume:

```bash
docker run --rm \
  -v hermes-agent-data:/opt/data \
  -v "$PWD/examples:/examples:ro" \
  alpine cp /examples/config.yaml.example /opt/data/config.yaml
```

## `Bind for 0.0.0.0:8642 failed: port is already allocated`

Sintoma:

```text
Bind for 0.0.0.0:8642 failed: port is already allocated
```

Causa:

A porta local `8642` ja esta em uso. Normalmente e um container Hermes anterior, outro Compose, ou algum processo local escutando na mesma porta.

No WSL/Linux, descubra quem usa a porta:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
ss -ltnp | grep ':8642'
```

Se for um container antigo do Hermes, pare/remova:

```bash
docker compose down
docker rm -f hermes-agent-local
```

Se estiver usando o modo volume:

```bash
./scripts/linux/stop.sh --volume
docker rm -f hermes-agent-local
```

Depois suba novamente:

```bash
./scripts/linux/start.sh --volume
```

Alternativa: trocar a porta publicada no `.env`:

```env
API_SERVER_PORT=8643
```

E subir novamente:

```bash
./scripts/linux/start.sh --volume
```

Nesse caso, use `http://127.0.0.1:8643` para acessar a API.

## Warning: volume already exists but was not created by Docker Compose

Sintoma:

```text
volume "hermes-agent-data" already exists but was not created by Docker Compose
```

Causa:

O volume foi criado pelo script de bootstrap com `docker volume create`, antes do Compose assumir a stack.

Solucao:

O arquivo `docker-compose.volume.yml` declara `hermes-agent-data` como volume externo. Se seu clone ainda mostra esse aviso, atualize o repositorio:

```bash
git pull
```

## Docker volume name includes invalid characters like `\r`

Sintoma:

```text
"hermes-agent-data\r" includes invalid characters for a local volume name
```

Causa:

O `.env` foi editado no Windows e salvo com CRLF. O caractere invisivel `\r` pode ser lido por scripts Bash no WSL se nao for tratado.

Solucao:

Atualize o repositorio. Os scripts atuais removem `\r`, espacos e aspas ao ler `HERMES_DATA_VOLUME`:

```bash
git pull
./scripts/linux/start.sh --volume
```

Alternativa manual:

```bash
sed -i 's/\r$//' .env
```

Depois rode novamente:

```bash
./scripts/linux/start.sh --volume
```

## `s6-overlay-suexec: fatal: can only run as pid 1`

Sintoma:

```text
s6-overlay-suexec: fatal: can only run as pid 1
```

Causa:

A imagem oficial do Hermes usa `s6-overlay` como sistema de inicializacao interno. Esse init precisa rodar como PID 1 dentro do container. Se o Compose adicionar outro init antes dele, por exemplo com `init: true`, o `s6-overlay` deixa de ser PID 1 e falha.

Solucao:

Atualize o repositorio e recrie o container:

```bash
git pull
./scripts/linux/stop.sh --volume
docker rm -f hermes-agent-local
./scripts/linux/start.sh --volume
```

No Windows PowerShell:

```powershell
git pull
.\scripts\windows\stop.ps1
docker rm -f hermes-agent-local
.\scripts\windows\start.ps1
```

## `No user allowlists configured`

Sintoma:

```text
WARNING gateway.run: No user allowlists configured. All unauthorized users will be denied.
```

Causa:

`API_SERVER_KEY` protege a API HTTP em `8642`, mas o gateway tambem tem uma camada separada de autorizacao para usuarios de plataformas como Telegram, Discord, Slack, Google Chat, WhatsApp, Signal e Matrix.

Para teste local, configure no `.env`:

```env
GATEWAY_ALLOW_ALL_USERS=true
```

Depois recrie o container:

```bash
./scripts/linux/stop.sh --volume
./scripts/linux/start.sh --volume
```

Para uso real, prefira manter:

```env
GATEWAY_ALLOW_ALL_USERS=false
```

E configure allowlists:

```env
GATEWAY_ALLOWED_USERS=
TELEGRAM_ALLOWED_USERS=
DISCORD_ALLOWED_USERS=
SLACK_ALLOWED_USERS=
GOOGLE_CHAT_ALLOWED_USERS=
WHATSAPP_ALLOWED_USERS=
SIGNAL_ALLOWED_USERS=
MATRIX_ALLOWED_USERS=
```
