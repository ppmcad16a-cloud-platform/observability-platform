# observability-platform

The MERN shop's **alert rules, recording rules and Grafana dashboards** - written once,
installed identically into all three clusters (GKE, AKS, EKS).

## Use (from a platform repo's addons stack)
```hcl
module "mern_observability" {
  source     = "git::https://github.com/ppmcad16a-cloud-platform/observability-platform.git//modules/mern-observability?ref=v1.0.0"
  cloud      = "gcp"   # gcp | azure | aws
  dashboards = true    # only where the central Grafana runs (GKE)
  depends_on = [helm_release.kube_prometheus_stack]
}
```

## Change an alert or dashboard
1. Edit `modules/mern-observability/chart/rules/*.yaml` or `dashboards/*.json`
   (build dashboards in Grafana, then *Export → JSON*).
2. Check: `helm lint`, and `promtool check rules` for rule files.
3. PR → merge → tag `v1.x.y` → bump `?ref=` in the three platform repos.
