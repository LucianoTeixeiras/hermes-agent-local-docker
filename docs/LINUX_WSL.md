# Guia Linux, WSL e Ubuntu - Hermes Agent Local Docker

## Requisitos

- Docker Engine ou Docker Desktop integrado ao WSL.
- Ubuntu/WSL com acesso ao comando `docker`.
- Bash.
- Git, se for contribuir com o projeto.

No WSL, confirme que o Docker esta acessivel:

```bash
docker version
docker compose version
```

## Setup inicial

Defina antes onde o projeto sera executado:

- Windows nativo com Docker Desktop: prefira uma pasta local como `D:\00-agents2ai-agents\hermes-agent-local-docker`.
- WSL/Linux: prefira o filesystem Linux, por exemplo `~/projects/hermes-agent-local-docker`.
- OneDrive: recomendado apenas como espelho, backup ou copia do repositorio, nao como local de execucao do Docker.

Copie o template de ambiente:

```bash
cp .env.example .env
```

Gere uma chave para `API_SERVER_KEY`:

```bash
openssl rand -hex 32
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

Garanta permissao de execucao nos scripts, se necessario:

```bash
chmod +x scripts/linux/*.sh
```

Execute o setup do Hermes:

```bash
./scripts/linux/bootstrap.sh
```

Com Nous Portal:

```bash
./scripts/linux/bootstrap.sh --portal
```

### WSL em `/mnt/c`, OneDrive ou filesystem Windows

Se aparecer uma mensagem parecida com esta durante o setup:

```text
s6-log: fatal: unable to fd_chmod /opt/data/logs/gateways/default/current: Operation not permitted
```

O problema normalmente nao e o Hermes em si. E o bind mount vindo de filesystem Windows/NTFS, pasta sincronizada ou caminho `/mnt/<drive>` no WSL, que pode nao suportar todas as operacoes de permissao esperadas pelo logger dentro do container.

Os scripts Linux detectam automaticamente WSL rodando em `/mnt/<drive>/...` e usam volume gerenciado pelo Docker. Se quiser deixar explicito, use:

```bash
./scripts/linux/bootstrap.sh --volume
```

Com Nous Portal:

```bash
./scripts/linux/bootstrap.sh --portal --volume
```

Depois suba o gateway com o mesmo modo:

```bash
./scripts/linux/start.sh --volume
```

Nesse modo, os dados ficam no volume Docker `hermes-agent-data`, nao na pasta local `hermes-data/`.

Tambem e possivel fixar esse comportamento no `.env`:

```env
HERMES_DATA_MODE=volume
HERMES_DATA_VOLUME=hermes-agent-data
```

Opcionalmente, use o exemplo de configuracao:

```bash
cp examples/config.yaml.example hermes-data/config.yaml
```

No modo `--volume`, copie o exemplo para dentro do volume Docker:

```bash
docker run --rm \
  -v hermes-agent-data:/opt/data \
  -v "$PWD/examples:/examples:ro" \
  alpine cp /examples/config.yaml.example /opt/data/config.yaml
```

Depois ajuste `provider`, `default`, aliases e modelos auxiliares conforme seus providers.

## Operacao

Subir:

```bash
./scripts/linux/start.sh
```

Quando usar volume gerenciado pelo Docker:

```bash
./scripts/linux/start.sh --volume
```

Se a porta `8642` ja estiver em uso, altere `API_SERVER_PORT` no `.env`, por exemplo:

```env
API_SERVER_PORT=8643
```

Depois suba novamente com o mesmo modo de volume.

Logs:

```bash
./scripts/linux/logs.sh
```

Quando usar volume gerenciado pelo Docker:

```bash
./scripts/linux/logs.sh --volume
```

Parar:

```bash
./scripts/linux/stop.sh
```

Quando usar volume gerenciado pelo Docker:

```bash
./scripts/linux/stop.sh --volume
```

## WSL: recomendacao de local do projeto

Para melhor performance, prefira manter o clone dentro do filesystem Linux do WSL, por exemplo:

```bash
~/projects/hermes-agent-local-docker
```

Evite operar volumes Docker pesados dentro de `/mnt/c/...`, `/mnt/d/...` ou outro caminho montado do Windows quando houver muitos arquivos, pois o desempenho de I/O pode ser pior.

Se precisar manter o projeto em `/mnt/<drive>` ou outro caminho do Windows, use o modo `volume`, que evita mensagens de permissao durante o setup interativo.

## Observacoes

- O volume persistente fica em `hermes-data/`.
- No modo `--volume`, o volume persistente fica em `hermes-agent-data`.
- As portas sao publicadas apenas em `127.0.0.1` por padrao.
- No WSL, `http://127.0.0.1:8642` normalmente fica acessivel tambem pelo navegador do Windows.
