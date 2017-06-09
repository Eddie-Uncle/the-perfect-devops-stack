job "wp-dev" {
  region = "global"

  datacenters = ["aws-east-1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  update {
    stagger = "30s"
    max_parallel = 1
  }

  group "wp-dev" {
    count = 20
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "wp-dev" {
      driver = "docker"

      config {
        volumes = [
          "/opt/${NOMAD_JOB_NAME}/:/var/www/html",
        ]
        image = "php:5.6-fpm"
      }

      resources {
        network {
          port "fpm" {}
        }
      }

      service {
        name = "php-app"
        port = "fpm"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
