# observability-platform

The MERN shop's **alert rules, recording rules and Grafana dashboards**, packaged as one versioned Terraform module. Every cluster installs the same tagged version, so monitoring behaves identically in GCP, Azure and AWS.

## Contents

```
modules/mern-observability/
├── main.tf, variables.tf, versions.tf     Terraform module: installs the chart below with helm_release
└── chart/
    ├── rules/recording.yaml                request rate, 5xx ratio, p95 latency per service and cloud
    ├── rules/alerts.yaml                   MernServiceDown, MernServiceDegraded, MernHighErrorRate,
    │                                       MernSlowResponses, MernPodRestarting
    ├── dashboards/mern-overview.json       "MERN shop - multi-cloud overview" (one row per cloud)
    ├── dashboards/mern-logs.json           "MERN shop - logs" (Loki)
    └── templates/                          PrometheusRule + Grafana dashboard ConfigMaps
```

| Alert | Fires when |
|---|---|
| MernServiceDown | a deployment in `mern` has no ready pod for 2 min (critical) |
| MernHighErrorRate | > 5 % of a service's requests return 5xx for 5 min (critical; health checks excluded) |
| MernServiceDegraded | fewer ready pods than wanted for 10 min |
| MernSlowResponses | p95 response time > 1 s for 10 min |
| MernPodRestarting | a container restarted more than twice in 15 min |

## Dependencies

| Depends on | For |
|---|---|
| kube-prometheus-stack in the target cluster | the `PrometheusRule` CRD and the Grafana sidecar that loads dashboards |
| service metrics from the shop | `http_request_duration_seconds` (Node, Python) and `http_server_requests_seconds` (Java) |

| Used by | |
|---|---|
| [gcp-platform](https://github.com/ppmcad16a-cloud-platform/gcp-platform), [azure-platform](https://github.com/ppmcad16a-cloud-platform/azure-platform), [aws-platform](https://github.com/ppmcad16a-cloud-platform/aws-platform) | `environments/prod/addons/monitoring.tf` |

## Usage

```hcl
module "mern_observability" {
  source     = "git::https://github.com/ppmcad16a-cloud-platform/observability-platform.git//modules/mern-observability?ref=v1.1.0"
  cloud      = "gcp"     # gcp | azure | aws — added as a label to every rule
  dashboards = true      # only where the central Grafana runs (GKE)
  depends_on = [helm_release.kube_prometheus_stack]
}
```

### Change an alert or a dashboard

1. Edit `chart/rules/*.yaml`, or build the dashboard in Grafana and paste *Export → JSON* into `chart/dashboards/`.
2. Check: `helm lint modules/mern-observability/chart` and `promtool check rules` on the rule files.
3. Pull request → merge → tag the next version (`v1.x.y`) → update `?ref=` in the three cloud repos.

## Versions

| Tag | Change |
|---|---|
| `v1.0.0` | first release: recording rules, 5 alerts, 2 dashboards |
| `v1.1.0` | `/api/health` traffic excluded from the error-rate rules (load-balancer health checks no longer inflate MernHighErrorRate) |
