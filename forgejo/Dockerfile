# https://contributors.home-assistant.io/apps/guides/dockerfile/
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.24
FROM ${BUILD_FROM}

# Managed by `mise run forgejo:pin` - do not edit by hand
ARG FORGEJO_VERSION=17.0.2
ARG FORGEJO_SHA256_AMD64=760cf8c6da9fb344908eebd1ebf920b79620fce6ebb22efa8f8c1e483652c1ee
ARG FORGEJO_SHA256_ARM64=3ff8d0dadec454b1a19b1a52aded435bb6ade3a3c7a0a60e023e6b4cacf080ed

ARG TARGETARCH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN \
    if [ -z "${TARGETARCH}" ]; then \
        echo "TARGETARCH is not set, please use Docker BuildKit for the build." && exit 1; \
    fi \
    && sha256_var="FORGEJO_SHA256_${TARGETARCH^^}" \
    && sha256="${!sha256_var:-}" \
    && if [ -z "${sha256}" ]; then \
        echo "Unsupported TARGETARCH: ${TARGETARCH} (no ${sha256_var}, see mise run forgejo:pin)" && exit 1; \
    fi \
    && apk add --no-cache \
        git \
        git-lfs \
        gnupg \
        openssh-keygen \
    && curl -sSLf -o /usr/local/bin/forgejo \
        "https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}/forgejo-${FORGEJO_VERSION}-linux-${TARGETARCH}" \
    && echo "${sha256}  /usr/local/bin/forgejo" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/forgejo \
    && addgroup -S -g 1000 git \
    && adduser -S -D -H -u 1000 -G git -h /data/forgejo -s /bin/bash git \
    && forgejo --version

# Copy root filesystem
COPY rootfs /

HEALTHCHECK --interval=30s --timeout=5s --start-period=5m --start-interval=5s \
    CMD ["curl", "-fsS", "-o", "/dev/null", "http://127.0.0.1:3000/api/healthz"]

LABEL \
    io.hass.type="app" \
    org.opencontainers.image.title="Home Assistant App: Forgejo" \
    org.opencontainers.image.description="Forgejo, a self-hosted lightweight software forge." \
    org.opencontainers.image.source="https://github.com/victor-vanherpt/ha-forgejo-app" \
    org.opencontainers.image.licenses="MIT"
