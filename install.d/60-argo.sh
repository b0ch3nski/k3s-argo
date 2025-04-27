VALUES="/tmp/values.yaml"

cat << EOF > "${VALUES}"
global:
  defaultStorageClass: local-path
rbac:
  singleNamespace: true

server:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 2
      memory: 2048Mi
  pdb:
    enabled: false
  networkPolicy:
    enabled: false
  containerSecurityContext:
    enabled: false
  serviceAccount:
    automountServiceAccountToken: true
  auth:
    enabled: true
    mode: server
  service:
    type: LoadBalancer
    ports:
      http: 2746

controller:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 2
      memory: 2048Mi
  pdb:
    enabled: false
  networkPolicy:
    enabled: false
  containerSecurityContext:
    enabled: false
  serviceAccount:
    automountServiceAccountToken: true
  workflowDefaults:
    spec:
      podSpecPatch: '{"initContainers":[{"name":"init","volumeMounts":[{"name":"tmp","mountPath":"/tmp"}]}],"volumes":[{"name":"tmp","emptyDir":{}}]}'
  persistence:
    archive:
      enabled: true

executor:
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 1
      memory: 1024Mi
  containerSecurityContext:
    enabled: false

workflows:
  serviceAccount:
    automountServiceAccountToken: true

postgresql:
  enabled: true
  primary:
    resources:
      requests:
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: 2
        memory: 2048Mi
    pdb:
      enabled: false
    networkPolicy:
      enabled: false
    persistence:
      enabled: true
      size: 20Gi
EOF

helm upgrade \
--install \
--values="${VALUES}" \
"argowf" \
"oci://registry-1.docker.io/bitnamicharts/argo-workflows" \
--version="${ARGO_VERSION}" \
--namespace="argowf" \
--create-namespace \
--timeout="15m" \
--wait \
--debug
