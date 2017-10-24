job "redisbatch" {
  region = "us-west-1"

  datacenters = ["us-west-1a", "us-west-1c"]

  type = "batch"

	group "cache" {

		count = 3

		restart {
			attempts = 2
			interval = "1m"
			delay = "10s"
			mode = "fail"
		}

		task "redisbatch" {
			driver = "docker"

			config {
				image = "redis:latest"
				port_map {
					db = 6379
				}
			}
			
			service {
				name = "${TASKGROUP}-redisbatch"
				tags = ["global", "cache"]
				port = "db"
				check {
					name = "alive"
					type = "tcp"
					interval = "10s"
					timeout = "2s"
				}
			}
			resources {
				network {
					mbits = 10
					port "db" {
					}
				}
			}
		}
	}
}
