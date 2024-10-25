# syntax=docker/dockerfile:1.9.0
ARG ALPINE_VERSION K3S_VERSION
FROM alpine:${ALPINE_VERSION} AS tools
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]

ARG HELM_VERSION K9S_VERSION ARGO_VERSION
RUN apk add --update --no-cache curl tar; \
    mkdir -p /tools; \
    curl -sSfL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -zxOf- linux-amd64/helm > /tools/helm; \
    curl -sSfL https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz | tar -zxOf- k9s > /tools/k9s; \
    curl -sSfL https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/argo-linux-amd64.gz | gunzip > /tools/argo; \
    chmod -R +x /tools

FROM rancher/k3s:v${K3S_VERSION} AS base

FROM scratch
COPY --from=base / /
COPY --from=tools /tools/ /usr/local/bin/

EXPOSE 6443/tcp 2746/tcp
ENV PATH=${PATH}:/bin/aux K3S_NODE_NAME=master K3S_TOKEN=t0k3n

CMD ["k3s", "server", "--disable=traefik,metrics-server", "--disable-network-policy", "--snapshotter=native"]
