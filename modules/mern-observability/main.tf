# Installs the MERN shop's recording rules, alert rules and (optionally)
# Grafana dashboards into ONE cluster. Every cloud calls the SAME tagged
# version of this module, so alerts and dashboards are identical everywhere.
resource "helm_release" "this" {
  name      = "mern-observability"
  chart     = "${path.module}/chart"
  namespace = var.namespace
  wait      = true

  values = [yamlencode({
    cloud = var.cloud
    dashboards = {
      enabled = var.dashboards
    }
  })]
}
