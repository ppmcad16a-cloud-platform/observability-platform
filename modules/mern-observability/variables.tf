variable "cloud" {
  description = "Which cloud this cluster is in"
  type        = string
  validation {
    condition     = contains(["gcp", "azure", "aws"], var.cloud)
    error_message = "cloud must be gcp, azure or aws."
  }
}

variable "dashboards" {
  description = "Install the Grafana dashboards - only where the central Grafana runs (GKE)"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Namespace of kube-prometheus-stack (Prometheus + Grafana)"
  type        = string
  default     = "monitoring"
}
