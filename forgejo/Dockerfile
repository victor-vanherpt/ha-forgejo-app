# https://contributors.home-assistant.io/apps/guides/dockerfile/
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.24
FROM ${BUILD_FROM}

# Managed by `mise run forgejo:pin` - do not edit by hand
ARG FORGEJO_VERSION=17.0.0
ARG FORGEJO_SHA256_AMD64=5a3b07e124ed70b4e46ee3939515f003bd3cc85352257a9a4607a527251042ca
ARG FORGEJO_SHA256_ARM64=e5ec437cd6357e8d1b4580cb47ab1daa58a32b33971a63db63446a535d33adb7

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

LABEL \
    io.hass.type="app" \
    org.opencontainers.image.title="Home Assistant App: Forgejo" \
    org.opencontainers.image.description="Forgejo, a self-hosted lightweight software forge." \
    org.opencontainers.image.source="https://github.com/victor-vanherpt/ha-forgejo-app" \
    org.opencontainers.image.licenses="MIT"
