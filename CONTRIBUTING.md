# Contributing

Contributions are welcome when they improve security, clarity, portability, or
operational reliability.

## Local Validation

Before opening a pull request, validate the Compose file:

```powershell
$env:API_SERVER_KEY='0123456789abcdef'
docker compose config --quiet
```

If you change scripts, test them on Windows PowerShell or PowerShell 7.

## Guidelines

- Do not commit `.env`, `hermes-data/`, logs, session data, or API keys.
- Keep defaults conservative and local-first.
- Prefer documented Hermes behavior over custom assumptions.
- Update both technical and executive documentation when the operational model
  changes.
