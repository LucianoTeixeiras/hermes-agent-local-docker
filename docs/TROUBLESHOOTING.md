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
