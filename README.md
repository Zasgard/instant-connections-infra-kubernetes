# instant-connections-infra-kubernetes

Umbrella Helm chart + CI workflow to deploy Instant Connections on Linode Kubernetes Engine (LKE).

## What this deploys

- `frontend` (ClusterIP, port 80, production static image)
- `backend` (ClusterIP, port 8000, production gunicorn image/command)
- `worker` (same backend image, `arq app.core.worker.settings.WorkerSettings`)
- `redis` (Bitnami dependency, internal)
- `postgres` (optional Bitnami dependency; managed DB recommended)
- `jitsi-web` (ClusterIP, ingress-terminated TLS)
- `jitsi-prosody` (ClusterIP ports 5222/5280/5347)
- `jitsi-jicofo` (internal deployment)
- `jitsi-jvb` (UDP `LoadBalancer` on 10000, not through ingress)
- `bot` (optional, disabled by default)
- `create-superuser` + `migrations` as optional Helm hook jobs

## Chart location

`/home/runner/work/instant-connections-infra-kubernetes/instant-connections-infra-kubernetes/charts/instant-connections`

## Ingress and TLS

- `app.example.com`
  - `/` -> frontend
  - `/api` -> backend
- `meet.example.com`
  - `/`, `/xmpp-websocket`, `/http-bind`, `/colibri-ws` -> jitsi-web
- TLS is handled by ingress + cert-manager (Let's Encrypt ClusterIssuer + Certificates).

## Critical Jitsi media config

Set these values before production deploy:

- `jitsi.publicUrl=https://meet.example.com`
- `jitsi.jvb.port=10000`
- `jitsi.jvb.advertiseIps` to the reachable public media IP(s)

If `JVB_ADVERTISE_IPS` is incorrect, conferences may connect but media will fail.

## Storage guidance

Backend defaults to PVC uploads mounted at `/home/app/uploads` with one replica.
For multi-replica backend, switch to object storage (`backend.uploads.objectStorage.enabled=true`) and store preview files there.

## CI/CD

Workflow: `.github/workflows/helm-deploy.yml`

- Pull requests: Helm dependency build + lint + template render validation
- Push to `main` / manual dispatch: same validation + `helm upgrade --install`

Required GitHub secret:

- `KUBECONFIG_B64`: base64-encoded kubeconfig for the target LKE cluster

Optional GitHub variable:

- `K8S_NAMESPACE` (defaults to `instant-connections`)

## Quick start

```bash
helm dependency build ./charts/instant-connections
helm upgrade --install instant-connections ./charts/instant-connections \
  --namespace instant-connections \
  --create-namespace
```
