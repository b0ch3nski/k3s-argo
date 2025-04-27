# syntax=docker/dockerfile:1.14-labs
ARG ALPINE_VERSION K3S_VERSION
FROM alpine:${ALPINE_VERSION} AS tools
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]

ARG TARGETARCH HELM_VERSION K9S_VERSION
RUN apk add --update --no-cache curl tar; \
    mkdir -p /tools; \
    curl --location --fail-with-body --no-progress-meter https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz | tar -zxOf- linux-${TARGETARCH}/helm > /tools/helm; \
    curl --location --fail-with-body --no-progress-meter https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz | tar -zxOf- k9s > /tools/k9s; \
    chmod -R +x /tools

FROM rancher/k3s:v${K3S_VERSION} AS base

FROM scratch
COPY --from=base / /
COPY --from=tools /tools/ /usr/local/bin/

ARG K3S_TOKEN=t0k3n
ENV PATH=${PATH}:/bin/aux K3S_NODE_NAME=master K3S_TOKEN=${K3S_TOKEN} K3S_KUBECONFIG_OUTPUT=/cfg/kubeconfig.yml KUBECONFIG=/cfg/kubeconfig.yml
CMD ["k3s", "server", "--disable=traefik,metrics-server", "--snapshotter=native", "--flannel-backend=host-gw"]
