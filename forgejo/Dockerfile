# https://contributors.home-assistant.io/apps/guides/dockerfile/
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.24
FROM ${BUILD_FROM}

# Managed by `mise run forgejo:pin` - do not edit by hand
ARG FORGEJO_VERSION=17.0.1
ARG FORGEJO_SHA256_AMD64=51a8cdf4a1252e79f4b3855d7a7891af6c6635105420768c460e2f0690385d6f
ARG FORGEJO_SHA256_ARM64=1e99403746406e8199efc903ddd1940d5728a60e50241f7aa6c9f2b907bd8ec9

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
