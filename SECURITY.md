# Security Policy

## Supported Versions

This repository is a deployment starter kit. Security updates are expected on
the default branch.

## Reporting a Vulnerability

Do not open public issues containing secrets, API keys, tokens, private logs,
session data, or host-specific security details.

For sensitive reports, contact the repository owner through a private channel
or GitHub private vulnerability reporting if enabled.

## Operational Guidance

- Keep `.env`, `hermes-data/`, and backups out of Git.
- Keep `API_SERVER_BIND=127.0.0.1` and `DASHBOARD_BIND=127.0.0.1` unless a
  reverse proxy, TLS, authentication, and firewall rules are configured.
- Do not enable `HERMES_DASHBOARD_INSECURE=1` on untrusted networks.
- Do not run two Hermes containers against the same `hermes-data/` directory.
- Rotate `API_SERVER_KEY` and provider credentials if a workstation or backup
  may have been exposed.
