# Troubleshooting

## `s6-log: fatal: unable to fd_chmod ... Operation not permitted`

Sintoma:

```text
s6-log: fatal: unable to fd_chmod /opt/data/logs/gateways/default/current: Operation not permitted
```

Causa comum:

O Hermes esta escrevendo logs em `/opt/data`, mas `/opt/data` foi montado a partir de uma pasta do Windows, OneDrive ou `/mnt/c` no WSL. Esse tipo de bind mount pode nao suportar todas as operacoes de permissao usadas pelo `s6-log`.

Solucao recomendada no WSL:

```bash
./scripts/linux/bootstrap.sh --volume
./scripts/linux/start.sh --volume
```

Se o projeto estiver em `/mnt/c/...`, os scripts Linux atuais escolhem `volume` automaticamente. O parametro `--volume` continua disponivel para deixar a intencao explicita.

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
