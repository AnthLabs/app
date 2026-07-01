output "hls_base_url" {
  description = "URL de base des assets HLS servis par le CDN local."
  value       = "http://localhost:${var.nginx_port}/media/hls"
}