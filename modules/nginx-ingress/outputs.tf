output "namespace" {
  description = "The namespace where NGINX Ingress Controller is deployed"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "helm_release_name" {
  description = "The name of the NGINX Ingress Helm release"
  value       = helm_release.nginx_ingress.name
}

output "helm_release_status" {
  description = "The status of the NGINX Ingress Helm release"
  value       = helm_release.nginx_ingress.status
}

output "chart_version" {
  description = "The version of NGINX Ingress Controller Helm chart"
  value       = var.chart_version
}