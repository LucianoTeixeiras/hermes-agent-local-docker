# Documento Executivo - Hermes Agent Local em Docker

## Resumo

Este projeto prepara uma instalacao local do Hermes Agent em Docker. A abordagem reduz risco operacional porque isola o servico em container, centraliza dados e credenciais em um volume controlado e evita exposicao de portas para a rede por padrao.

## O que sera entregue

- Ambiente Docker local para executar o Hermes Agent.
- Persistencia de configuracoes, sessoes, memorias, skills e logs.
- Scripts simples de inicializacao, execucao, parada e acompanhamento para Windows e Linux/WSL/Ubuntu.
- Controles basicos de seguranca: API key obrigatoria, portas locais, dados fora do repositorio e limites de recursos.
- Documentacao tecnica e executiva para compartilhamento interno.

## Beneficios

- Seguranca: o servico roda isolado e nao fica aberto na rede por padrao.
- Reprodutibilidade: o mesmo Compose pode ser usado por outros membros da equipe.
- Compatibilidade: operacao documentada para Windows nativo e para usuarios WSL/Linux.
- Governanca: credenciais e dados sensiveis ficam separados do codigo.
- Manutencao: atualizacoes da imagem podem ser feitas sem apagar configuracoes.
- Escalabilidade operacional: o Hermes permite multiplos perfis para separar agentes, objetivos ou times.

## Riscos e mitigacoes

- Exposicao indevida da API ou dashboard: mitigada por bind em `127.0.0.1` e API key obrigatoria.
- Vazamento de segredos: mitigado por `.gitignore`, armazenamento em volume local e recomendacao de backup criptografado.
- Corrupcao de sessoes por concorrencia: mitigada pela regra de nao usar dois containers no mesmo volume.
- Dependencia de imagem externa: mitigada por possibilidade de fixar versao em `HERMES_IMAGE_TAG`.

## Decisoes de desenho

- O estado do Hermes fica em `hermes-data/`, mapeado para `/opt/data` no container.
- O gateway sobe como servico persistente com restart automatico.
- O dashboard nasce desligado, pois a documentacao oficial exige OAuth ou um modo inseguro explicitamente assumido.
- As portas `8642` e `9119` sao publicadas apenas localmente.

## Proximos passos recomendados

1. Definir o provedor de modelo e registrar as chaves no setup inicial.
2. Decidir se o dashboard sera usado e, se sim, configurar OAuth.
3. Definir politica de backup do diretorio `hermes-data/`.
4. Pinagem de versao da imagem para ambientes homologados.
5. Documentar quais times ou usuarios podem operar o agente e acessar os dados persistidos.
