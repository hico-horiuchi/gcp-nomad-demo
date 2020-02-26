---
consul:
  datacenter: nomad-demo
  encrypt: ${consul_encrypt}
  version: 1.7.1
google:
  credenetials: ${google_credenetials}
  project: ${google_project}
  region: ${google_region}
nomad:
  datacenter: nomad-demo
  encrypt: ${nomad_encrypt}
  job_gc_interval: 5m
  job_gc_threshold: 30s
  version: 0.10.4
