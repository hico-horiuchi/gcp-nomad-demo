job "webapp" {
  datacenters = ["nomad-demo"]

  group "webapp" {
    count = 3

    task "webapp" {
      config {
        image = "hashicorp/demo-webapp-lb-guide"
      }

      driver = "docker"

      env {
        NODE_IP = "${NOMAD_IP_http}"
        PORT    = "${NOMAD_PORT_http}"
      }

      resources {
        network {
          port "http" {}
        }
      }

      service {
        name = "webapp"
        port = "http"

        tags = [
          "traefik.frontend.rule=PathPrefixStrip:/webapp",
          "traefik.tags=service",
        ]

        check {
          interval = "10s"
          path     = "/"
          timeout  = "10s"
          type     = "http"
        }
      }
    }
  }
}
