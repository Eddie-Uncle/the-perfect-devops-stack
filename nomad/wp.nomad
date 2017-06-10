job "wp" {
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
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "wp-dev" {
      driver = "docker"

      config {
        image = "stackhead:5000/phpfpm:0.1"
        volumes = [
          "/mnt/efs/${NOMAD_TASK_NAME}/:/var/www/html",
        ]

        network_mode = "bridge"
        port_map {
          fpm = 9000
        }
      }

      resources {
        memory = 384
        network {
          port "fpm" {}
        }
      }

      service {
        name = "wp-dev"
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
  group "wp-prod" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "wp-prod" {
      driver = "docker"

      config {
        image = "stackhead:5000/phpfpm:0.1"
        volumes = [
          "/mnt/efs/${NOMAD_TASK_NAME}/:/var/www/html",
        ]

        network_mode = "bridge"
        port_map {
          fpm = 9000
        }
      }

      resources {
        memory = 384
        network {
          port "fpm" {}
        }
      }

      service {
        name = "wp-prod"
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
