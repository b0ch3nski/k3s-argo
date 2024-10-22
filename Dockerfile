# syntax=docker/dockerfile:1.9.0
ARG K3S_VERSION
FROM rancher/k3s:${K3S_VERSION} AS base

FROM scratch
COPY --from=base / /

EXPOSE 6443/tcp 2746/tcp
ENV PATH=${PATH}:/bin/aux K3S_NODE_NAME=master K3S_TOKEN=t0k3n

CMD ["k3s", "server", "--disable=traefik,metrics-server", "--disable-network-policy", "--snapshotter=native"]
