job "traefik" {
  datacenters = ["nomad-demo"]
  priority    = 100
  type        = "system"

  group "traefik" {
    task "traefik" {
      config {
        image        = "traefik:1.7"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      driver = "docker"

      resources {
        network {
          port "api" {
            static = 8081
          }

          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "traefik"

        check {
          interval = "10s"
          port     = "http"
          timeout  = "10s"
          type     = "tcp"
        }
      }

      template {
        data = <<EOF
[api]
dashboard = true

[consulCatalog]
constraints = ["tag==service"]
domain = "consul.localhost"
endpoint = "127.0.0.1:8500"
prefix = "traefik"

[entryPoints]
[entryPoints.http]
address = ":8080"
[entryPoints.traefik]
address = ":8081"
EOF

        destination = "local/traefik.toml"
      }
    }
  }
}
