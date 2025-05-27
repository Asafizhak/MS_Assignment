variable "chart_version" {
  description = "Version of the NGINX Ingress Helm chart"
  type        = string
  default     = "4.8.3"
}

variable "replica_count" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 1
}