output "app_container_name" {
  value = docker_container.app.name
}

output "network_name" {
  value = docker_network.mecaniqa_net.name
}

output "app_url" {
  value = "http://localhost:8080"
}
