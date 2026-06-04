# Guia Hermes Desktop - Backend Docker

Este guia conecta o Hermes Desktop nativo ao Hermes Agent rodando no Docker deste projeto.

## Conceito

Hermes Desktop usa o backend do **dashboard**:

```text
http://localhost:9119
```

Clientes OpenAI-compatible usam a API:

```text
http://localhost:8642/v1
```

Nao confunda os dois endpoints.

## 1. Configurar autenticacao do dashboard

Edite o `.env` do clone operacional e configure:

```env
HERMES_DASHBOARD=1
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=escolha-uma-senha-forte
HERMES_DASHBOARD_BASIC_AUTH_SECRET=gere-uma-chave-estavel
```

Gere o secret no WSL/Linux:

```bash
openssl rand -base64 32
```

Ou no PowerShell:

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

O `HERMES_DASHBOARD_BASIC_AUTH_SECRET` deve ser estavel. Se ele mudar a cada boot, o Desktop pode perder a sessao.

## 2. Reiniciar o container

WSL/Linux usando volume:

```bash
./scripts/linux/stop.sh --volume
./scripts/linux/start.sh --volume
```

Windows PowerShell:

```powershell
.\scripts\windows\stop.ps1
.\scripts\windows\start.ps1
```

## 3. Testar o status do dashboard

WSL/Linux:

```bash
curl -s http://localhost:9119/api/status
```

Para ver apenas os campos de autenticacao sem instalar `jq`:

```bash
curl -s http://localhost:9119/api/status | python3 -m json.tool
```

Ou:

```bash
python3 - <<'PY'
import json, urllib.request
data = json.load(urllib.request.urlopen("http://localhost:9119/api/status"))
print("auth_required:", data.get("auth_required"))
print("auth_providers:", data.get("auth_providers"))
PY
```

Se tiver `jq`, tambem pode usar:

```bash
curl -s http://localhost:9119/api/status | jq '.auth_required, .auth_providers'
```

Esperado para o Hermes Desktop:

```text
true
[
  "basic"
]
```

Se `basic` nao aparecer, o Desktop tende a pedir `Session token` em vez de mostrar `Sign in`.

## 4. Configurar no Hermes Desktop

Na tela:

```text
Settings -> Gateway -> Remote gateway
```

Primeiro selecione o card:

```text
Remote gateway
```

Se o card `Local gateway` continuar selecionado, o botao `Test remote` pode permanecer desabilitado mesmo com a URL preenchida.

Preencha:

```text
Remote URL: http://localhost:9119
Session token: deixe em branco
```

Clique:

```text
Test remote
Save and reconnect
```

Quando o Desktop detectar Basic Auth, ele deve mostrar o fluxo de login. Use:

```text
Username: admin
Password: a senha definida no .env
```

## 5. Se a tela pedir Session token

Isso normalmente significa que o provider de Basic Auth nao esta ativo no backend.

Verifique:

```bash
curl -s http://localhost:9119/api/status
```

Sem `jq`, use:

```bash
curl -s http://localhost:9119/api/status | python3 -m json.tool
```

Confirme no `.env`:

```env
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=
HERMES_DASHBOARD_BASIC_AUTH_SECRET=
```

Depois reinicie o container.

## 6. Se o botao Test remote nao habilitar

Verifique:

1. O card `Remote gateway` esta selecionado.
2. A URL esta sem barra final:

   ```text
   http://localhost:9119
   ```

3. Se `localhost` nao funcionar no Windows, tente:

   ```text
   http://127.0.0.1:9119
   ```

4. O backend esta acessivel:

   ```bash
   curl -s http://localhost:9119/api/status | python3 -m json.tool
   ```

5. Se alterou `.env`, reiniciou o container:

   ```bash
   ./scripts/linux/stop.sh --volume
   ./scripts/linux/start.sh --volume
   ```

6. Feche e abra o Hermes Desktop novamente. Algumas builds mantem estado de formulario em memoria ate reiniciar a janela.

## 7. Fallback: configurar Remote URL por variavel de ambiente

A documentacao oficial tambem permite definir o backend remoto via variavel `HERMES_DESKTOP_REMOTE_URL` antes de abrir o Hermes Desktop.

Windows PowerShell, para a sessao atual:

```powershell
$env:HERMES_DESKTOP_REMOTE_URL="http://127.0.0.1:9119"
```

Para persistir no usuario Windows:

```powershell
setx HERMES_DESKTOP_REMOTE_URL "http://127.0.0.1:9119"
```

Depois feche e abra o Hermes Desktop.

Se o Desktop detectar Basic Auth, ele deve pedir login com:

```text
Username: admin
Password: valor de HERMES_DASHBOARD_BASIC_AUTH_PASSWORD
```

Para remover o override persistente depois:

```powershell
Remove-ItemProperty -Path "HKCU:\Environment" -Name HERMES_DESKTOP_REMOTE_URL
```

## 8. Seguranca

- Nao exponha `9119` na internet.
- Mantenha `DASHBOARD_BIND=127.0.0.1` para uso local.
- Para acesso remoto real, use VPN/Tailscale e autentique o dashboard.
- Evite `HERMES_DASHBOARD_INSECURE=1`.

## Referencias oficiais

- Hermes Desktop: https://hermes-agent.nousresearch.com/docs/user-guide/desktop
- API Server: https://hermes-agent.nousresearch.com/docs/user-guide/features/api-server/
