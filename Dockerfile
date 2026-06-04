ARG HERMES_IMAGE_TAG=latest

FROM nousresearch/hermes-agent:${HERMES_IMAGE_TAG}

LABEL org.opencontainers.image.title="Hermes Agent Local Docker"
LABEL org.opencontainers.image.description="Local hardened wrapper for Nous Research Hermes Agent"
LABEL org.opencontainers.image.source="https://hermes-agent.nousresearch.com/docs/user-guide/docker"

USER root
RUN mkdir -p /opt/data

VOLUME ["/opt/data"]

EXPOSE 8642 9119

CMD ["gateway", "run"]
