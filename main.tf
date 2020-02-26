provider "google" {
  credentials = file(lookup(var.google_config, "credentials"))
  project     = lookup(var.google_config, "project")
  region      = lookup(var.google_config, "region")
  zone        = lookup(var.google_config, "zone")
}

data "template_file" "all_yml" {
  template = file("group_vars/all.yml.tpl")

  vars = {
    consul_encrypt      = random_id.encrypt.b64_std
    google_credenetials = lookup(var.google_config, "credentials")
    google_project      = lookup(var.google_config, "project")
    google_region       = lookup(var.google_config, "region")
    nomad_encrypt       = random_id.encrypt.b64_std
  }
}

data "template_file" "hosts" {
  template = file("hosts.tpl")

  vars = {
    nomad_servers  = join("\n", google_compute_instance.nomad_server.*.network_interface.0.access_config.0.nat_ip)
    consul_servers = join("\n", google_compute_instance.nomad_server.*.network_interface.0.access_config.0.nat_ip)
  }
}

resource "random_id" "encrypt" {
  byte_length = 32
}

resource "google_compute_network" "nomad_network" {
  name = "nomad-network"
}

resource "google_compute_firewall" "allow_ssh" {
  name        = "nomad-allow-ssh"
  network     = google_compute_network.nomad_network.name
  priority    = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_icmp" {
  name        = "nomad-allow-icmp"
  network     = google_compute_network.nomad_network.name
  priority    = "65534"

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  name          = "nomad-allow-health-checks"
  network       = google_compute_network.nomad_network.name
  priority      = "65534"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name          = "nomad-allow-internal"
  network       = google_compute_network.nomad_network.name
  priority      = "65534"
  source_ranges = ["10.128.0.0/9"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_instance" "nomad_server" {
  count        = 3
  name         = format("nomad-server-%02d", count.index + 1)
  machine_type = "n1-standard-1"
  tags         = ["consul-server", "nomad-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.nomad_network.name
    access_config {
    }
  }
}

resource "google_compute_instance_group" "nomad_server_group" {
  name      = "nomad-server-group"
  instances = google_compute_instance.nomad_server.*.self_link

  named_port {
    name = "http"
    port = "8080"
  }
}

resource "null_resource" "all_yml" {
  triggers = {
    rendered = data.template_file.all_yml.rendered
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.all_yml.rendered}\" > group_vars/all.yml"
  }
}

resource "null_resource" "hosts" {
  triggers = {
    rendered = data.template_file.hosts.rendered
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.hosts.rendered}\" > hosts"
  }
}
