# Trocar Modelo no Hermes via Docker

Este guia mostra como alterar o modelo principal do Hermes Agent quando ele esta rodando pelo Docker deste projeto.

## Pre-requisitos

- Container `hermes-agent-local` em execucao.
- Provider/API key configurados no `.env` ou em `/opt/data/.env`.
- Em WSL sobre `/mnt/<drive>`, use o modo volume.

## 1. Abrir o menu interativo

WSL/Linux com volume:

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config
```

Windows ou Linux usando bind mount padrao:

```bash
docker compose exec hermes hermes config
```

## 2. Editar o config.yaml pelo Hermes

WSL/Linux com volume:

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config edit
```

Windows ou Linux usando bind mount padrao:

```bash
docker compose exec hermes hermes config edit
```

## 3. Setar o modelo diretamente

Formato geral:

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config set model <provider/model>
```

Exemplos:

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config set model openrouter/anthropic/claude-sonnet-4.6
```

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config set model openrouter/google/gemini-2.5-pro
```

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config set model openai/gpt-5
```

### NVIDIA Nemotron free endpoint

A NVIDIA oferece endpoints gratuitos para prototipagem no NIM API Catalog. Para o Nemotron 3 Super:

```env
NVIDIA_API_KEY=sua_chave_nvidia
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1
```

Modelo:

```text
nvidia/nemotron-3-super-120b-a12b
```

No Hermes, usando o formato `<provider/model>`, o comando fica:

```bash
docker compose -f docker-compose.yml -f docker-compose.volume.yml exec hermes hermes config set model nvidia/nvidia/nemotron-3-super-120b-a12b
```

Se preferir via `config.yaml`:

```yaml
model:
  provider: nvidia
  default: nvidia/nemotron-3-super-120b-a12b
  base_url: ${NVIDIA_BASE_URL}
  api_mode: chat_completions
```

Tambem ha um alias em `examples/config.yaml.example`:

```yaml
model_aliases:
  nemotron-free:
    provider: nvidia
    model: nvidia/nemotron-3-super-120b-a12b
    base_url: ${NVIDIA_BASE_URL}
```

## 4. Reiniciar o gateway

WSL/Linux com volume:

```bash
./scripts/linux/stop.sh --volume
./scripts/linux/start.sh --volume
```

Windows:

```powershell
.\scripts\windows\stop.ps1
.\scripts\windows\start.ps1
```

## 5. Validar

Defina a chave da API:

```bash
export HERMES_API_KEY='sua_api_server_key'
```

Liste modelos:

```bash
curl http://127.0.0.1:8642/v1/models \
  -H "Authorization: Bearer $HERMES_API_KEY"
```

Faca uma chamada simples:

```bash
curl http://127.0.0.1:8642/v1/chat/completions \
  -H "Authorization: Bearer $HERMES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "hermes-agent",
    "messages": [
      {
        "role": "user",
        "content": "Qual modelo principal esta configurado agora?"
      }
    ]
  }'
```

## 6. Acessar config.yaml no volume Docker

Quando usar `--volume`, o `config.yaml` fica dentro do volume Docker `hermes-agent-data`, em:

```text
/opt/data/config.yaml
```

Abrir um shell temporario:

```bash
docker run -it --rm -v hermes-agent-data:/opt/data alpine sh
```

Inspecionar o config:

```sh
cat /opt/data/config.yaml
```

## Observacoes

- As chaves dos providers ficam no `.env` ou em `/opt/data/.env`.
- O modelo principal fica em `config.yaml`.
- O comando `hermes config set model` altera a configuracao persistente do Hermes.
- Reinicie o gateway depois de alterar modelo para garantir que novas sessoes carreguem a configuracao.
