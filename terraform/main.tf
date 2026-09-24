terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Rede interna para DNS entre os containers
resource "docker_network" "mecaniqa_net" {
  name = "mecaniqa-net"
}

# Volumes para persistencia de dados
resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}

resource "docker_volume" "redis_data" {
  name = "redis_data"
}

# Imagens construidas a partir dos Dockerfiles proprios do projeto
resource "docker_image" "db" {
  name = "mecaniqa-db:latest"
  build {
    context = "${path.module}/../db"
  }
}

resource "docker_image" "cache" {
  name = "mecaniqa-cache:latest"
  build {
    context = "${path.module}/../cache"
  }
}

resource "docker_image" "app" {
  name = "mecaniqa-api:latest"
  build {
    context = "${path.module}/.."
  }
}

resource "docker_container" "db" {
  name  = "mecaniqa-db"
  image = docker_image.db.image_id

  env = [
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
  ]

  networks_advanced {
    name = docker_network.mecaniqa_net.name
  }

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  ports {
    internal = 3306
    external = 3306
  }
}

resource "docker_container" "cache" {
  name  = "mecaniqa-cache"
  image = docker_image.cache.image_id

  networks_advanced {
    name = docker_network.mecaniqa_net.name
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  ports {
    internal = 6379
    external = 6379
  }
}

resource "docker_container" "app" {
  name  = "mecaniqa-api"
  image = docker_image.app.image_id

  env = [
    "SPRING_DATASOURCE_URL=jdbc:mysql://mecaniqa-db:3306/${var.mysql_database}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
    "SPRING_DATASOURCE_USERNAME=${var.mysql_user}",
    "SPRING_DATASOURCE_PASSWORD=${var.mysql_password}",
    "SPRING_DATA_REDIS_HOST=mecaniqa-cache",
    "SPRING_DATA_REDIS_PORT=6379",
  ]

  networks_advanced {
    name = docker_network.mecaniqa_net.name
  }

  ports {
    internal = 8080
    external = 8080
  }

  depends_on = [docker_container.db, docker_container.cache]
}
