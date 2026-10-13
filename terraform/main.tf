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
    external = 3307
  }

  # Healthcheck: o Terraform so avanca para a API quando o MySQL responder
  healthcheck {
    test         = ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${var.mysql_root_password}"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 5
    start_period = "30s"
  }

  # Aguarda o container ficar "healthy" antes de considerar o recurso criado
  wait         = true
  wait_timeout = 120
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

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  wait         = true
  wait_timeout = 60
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
    external = 8081
  }

  # Rede de seguranca: se a API cair (ex.: conexao recusada), tenta subir de novo
  restart         = "on-failure"
  max_retry_count = 10

  # Com wait = true nos recursos abaixo, isso espera db e cache ficarem saudaveis
  depends_on = [docker_container.db, docker_container.cache]
}
