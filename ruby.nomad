job "ruby" {
  datacenters = ["nomad-demo"]
  type        = "batch"

  group "ruby" {
    reschedule {
      attempts = 0
    }

    restart {
      attempts = 0
    }

    task "ruby" {
      config {
        args = ["${NOMAD_TASK_DIR}/script.rb"]
        command = "ruby"
        image   = "ruby:2.7"
      }

      dispatch_payload {
        file = "script.rb"
      }

      driver = "docker"

      env {
        SLACK_INCOMING_WEBHOOK_URL = "${NOMAD_META_SLACK_INCOMING_WEBHOOK_URL}"
      }
    }
  }

  meta {
    slack_incoming_webhook_url = ""
  }

  parameterized {
    payload       = "required"
    meta_required = ["slack_incoming_webhook_url"]
  }
}
