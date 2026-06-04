# Guia Telegram - Hermes Agent Local Docker

Este guia configura o Hermes Agent como bot do Telegram usando o projeto Docker deste repositorio.

## Pre-requisitos

- Container Hermes subindo corretamente.
- Modelo/provider ja configurado.
- Acesso ao Telegram.
- `.env` local criado a partir de `.env.example`.

No seu caso WSL em `/mnt/d/...`, mantenha o modo volume:

```bash
./scripts/linux/start.sh --volume
```

## 1. Criar o bot no BotFather

No Telegram:

1. Abra `@BotFather` ou acesse https://t.me/BotFather.
2. Envie `/newbot`.
3. Escolha o nome visivel do bot, por exemplo `Hermes Local Agent`.
4. Escolha um username unico terminado em `bot`, por exemplo `meu_hermes_local_bot`.
5. Copie o token gerado.

O token parece com:

```text
123456789:ABCdefGHIjklMNOpqrSTUvwxYZ
```

Mantenha esse token em segredo. Se ele vazar, use `/revoke` no BotFather.

## 2. Configurar comandos do bot

Opcional, mas recomendado. No `@BotFather`, use `/setcommands` e cadastre:

```text
help - Show help information
new - Start a new conversation
sethome - Set this chat as the home channel
```

## 3. Descobrir seu Telegram user ID

O Hermes usa ID numerico, nao o seu `@username`.

Opcoes simples:

- Envie mensagem para `@userinfobot`.
- Ou envie mensagem para `@get_id_bot`.

Guarde o numero retornado, por exemplo:

```text
123456789
```

## 4. Configurar o `.env`

Edite o `.env` do clone operacional e preencha:

```env
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrSTUvwxYZ
TELEGRAM_ALLOWED_USERS=123456789
GATEWAY_ALLOW_ALL_USERS=false
```

Para varios usuarios:

```env
TELEGRAM_ALLOWED_USERS=123456789,987654321
```

Para teste local rapido, voce pode liberar todos:

```env
GATEWAY_ALLOW_ALL_USERS=true
```

Mas para uso real, mantenha `false` e use allowlist explicita.

## 5. Reiniciar o gateway

WSL/Linux usando volume:

```bash
./scripts/linux/stop.sh --volume
./scripts/linux/start.sh --volume
./scripts/linux/logs.sh --volume
```

Windows PowerShell:

```powershell
.\scripts\windows\stop.ps1
.\scripts\windows\start.ps1
.\scripts\windows\logs.ps1
```

O log deve indicar que o gateway iniciou. Depois, envie uma mensagem direta para o bot no Telegram.

## 6. Testar

No Telegram, abra o bot e envie:

```text
/help
```

Depois teste uma mensagem simples:

```text
Oi Hermes, responda em uma frase: voce esta online?
```

## Grupos do Telegram

Por padrao, bots do Telegram usam privacy mode. Em grupos, isso significa que o bot so ve:

- comandos iniciados com `/`;
- respostas diretas a mensagens do bot;
- mensagens de servico;
- mensagens em canais/grupos onde o bot e admin.

Para grupos, configure pelo BotFather:

1. Envie `/mybots`.
2. Selecione o bot.
3. Bot Settings -> Group Privacy.
4. Desative privacy mode ou promova o bot a admin no grupo.
5. Remova e adicione o bot novamente ao grupo depois da mudanca.

Para evitar resposta em qualquer conversa do grupo, use configuracao no `config.yaml`:

```yaml
telegram:
  require_mention: true
  exclusive_bot_mentions: true
```

## Canais e home channel

Use `/sethome` em uma conversa do Telegram para definir onde tarefas agendadas devem entregar resultados.

Tambem e possivel configurar manualmente:

```env
TELEGRAM_HOME_CHANNEL=-1001234567890
TELEGRAM_HOME_CHANNEL_NAME=Meu Canal
```

IDs de grupos e canais geralmente sao negativos.

## Polling vs webhook

Para ambiente local, WSL, Docker Desktop ou VPS sempre ligado, use o modo padrao por polling. Nao precisa configurar webhook.

Webhook e recomendado apenas quando voce tem uma URL HTTPS publica para receber chamadas do Telegram:

```env
TELEGRAM_WEBHOOK_URL=https://seu-dominio.com/telegram
TELEGRAM_WEBHOOK_SECRET=<gerado-com-openssl-rand-hex-32>
TELEGRAM_WEBHOOK_PORT=8443
```

## Troubleshooting rapido

### Bot nao responde em DM

Verifique:

```bash
./scripts/linux/logs.sh --volume
```

E confirme no `.env`:

```env
TELEGRAM_BOT_TOKEN=
TELEGRAM_ALLOWED_USERS=
```

### Bot responde para ninguem

Provavel allowlist ausente. Para uso seguro:

```env
TELEGRAM_ALLOWED_USERS=seu_user_id_numerico
```

Para teste local:

```env
GATEWAY_ALLOW_ALL_USERS=true
```

### Funciona em DM, mas nao em grupo

Confira:

- privacy mode no BotFather;
- se o bot foi removido e adicionado novamente ao grupo apos mudar privacy;
- se o usuario que envia mensagens esta em `TELEGRAM_ALLOWED_USERS`;
- se voce esta mencionando o bot quando `telegram.require_mention: true`.

## Referencias oficiais

- Telegram Setup: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram
- Messaging Gateway: https://hermes-agent.nousresearch.com/docs/user-guide/messaging
- Team Telegram Assistant: https://hermes-agent.nousresearch.com/docs/guides/team-telegram-assistant/
