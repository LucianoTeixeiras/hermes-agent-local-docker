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
OPENAI_BASE_URL=
```

Para configuracao permanente pelo proprio Hermes, use o setup interativo ou `hermes config set`, que grava segredos em `hermes-data/.env`.

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

Opcionalmente, use o exemplo de configuracao:

```bash
cp examples/config.yaml.example hermes-data/config.yaml
```

Depois ajuste `provider`, `default`, aliases e modelos auxiliares conforme seus providers.

## Operacao

Subir:

```bash
./scripts/linux/start.sh
```

Logs:

```bash
./scripts/linux/logs.sh
```

Parar:

```bash
./scripts/linux/stop.sh
```

## WSL: recomendacao de local do projeto

Para melhor performance, prefira manter o clone dentro do filesystem Linux do WSL, por exemplo:

```bash
~/projects/hermes-agent-local-docker
```

Evite operar volumes Docker pesados dentro de `/mnt/c/...` quando houver muitos arquivos, pois o desempenho de I/O pode ser pior.

## Observacoes

- O volume persistente fica em `hermes-data/`.
- As portas sao publicadas apenas em `127.0.0.1` por padrao.
- No WSL, `http://127.0.0.1:8642` normalmente fica acessivel tambem pelo navegador do Windows.
