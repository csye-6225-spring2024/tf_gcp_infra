# This Terraform configuration sets up networking resources on GCP.
# It creates VPC with two subnets: webapp and db, and adds a route to vpc.
# Provider configuration for GCP
provider "google" {
  project = var.project_id
  region  = var.region
}

# Resource to create VPC
resource "google_compute_network" "my_vpc" {
  name                            = var.vpc_name
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

# Resource to create subnet named webapp
resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  region        = var.region
  network       = google_compute_network.my_vpc.self_link
  ip_cidr_range = var.webapp_subnet_cidr
}

# Resource to create subnet named db
resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  region        = var.region
  network       = google_compute_network.my_vpc.self_link
  ip_cidr_range = var.db_subnet_cidr
}

# resource "google_compute_subnetwork" "load_balancer_subnet" {
#   name          = var.load_balancer_subnet_name
#   region        = var.region
#   network       = google_compute_network.my_vpc.self_link
#   ip_cidr_range = var.load_balancer_subnet_cidr
# }

# Resource to create route for webapp subnet
resource "google_compute_route" "vpc_route" {
  name             = var.vpc_route_name
  network          = google_compute_network.my_vpc.self_link
  dest_range       = var.route_range
  next_hop_gateway = var.next_hop_gateway
}

# Resource to create firewall
# resource "google_compute_firewall" "vpc_firewall" {
#   name     = var.firewall_http
#   network  = google_compute_network.my_vpc.self_link
#   priority = var.priority_allow

#   allow {
#     protocol = var.protocol_http
#     ports    = var.ports_http
#   }

#   source_ranges = var.source_ranges_http
#   target_tags   = var.target_tags_http
# }


# Resource to deny firewall
resource "google_compute_firewall" "deny-ssh" {
  name    = var.firewall_ssh
  network = google_compute_network.my_vpc.self_link
  # priority = var.priority_deny

  deny {
    protocol = var.protocol_ssh
    ports    = var.ports_ssh
  }

  source_ranges = var.source_ranges_ssh
  target_tags   = var.target_tags_http
}

# Create the CloudSQL instance
resource "google_sql_database_instance" "cloudsql_instance" {
  name                = var.cloudsql_instance_name
  deletion_protection = var.delete_protection
  region              = var.region
  database_version    = var.database_version
  encryption_key_name = google_kms_crypto_key.cloudsql_crypto_key.id

  settings {
    tier              = var.google_sql_database_instance_tier
    availability_type = var.google_sql_database_instance_availability_type
    disk_type         = var.google_sql_database_disk_type
    disk_size         = var.google_sql_database_disk_size

    backup_configuration {
      enabled            = var.backup_configuration_enabled
      binary_log_enabled = var.backup_configuration_binary_log_enabled
    }
    ip_configuration {
      psc_config {
        psc_enabled               = var.psc_config_psc_enabled
        allowed_consumer_projects = [var.project_id]
      }
      ipv4_enabled = var.psc_config_ipv4_enabled
    }
  }
  # depends_on = [
  #   google_kms_crypto_key.cloudsql_crypto_key

  # ]
}
# resource "google_compute_global_address" "peer_address" {
#   name          = var.google_compute_global_address_name
#   address_type  = var.google_compute_global_address_type
#   prefix_length = var.google_compute_global_address_prefix_length
#   purpose       = var.google_compute_global_address_purpose
#   network       = google_compute_network.my_vpc.id
# }
# resource "google_service_networking_connection" "private_connection" {
#   network                 = google_compute_network.my_vpc.id
#   service                 = var.google_service_networking_connection_service
#   reserved_peering_ranges = [google_compute_global_address.peer_address.name]
# }
resource "google_compute_address" "endpointip" {
  name         = "psc-compute-address-${google_sql_database_instance.cloudsql_instance.name}"
  region       = var.region
  address_type = var.google_compute_address_type
  subnetwork   = google_compute_subnetwork.db_subnet.id
  address      = var.google_compute_address_endpoint
}

resource "google_compute_forwarding_rule" "default" {
  name                  = "psc-forwarding-rule-${google_sql_database_instance.cloudsql_instance.name}"
  region                = var.region
  subnetwork            = google_compute_subnetwork.db_subnet.id
  ip_address            = google_compute_address.endpointip.id
  load_balancing_scheme = ""
  target                = google_sql_database_instance.cloudsql_instance.psc_service_attachment_link
}

# Create a database in the CloudSQL instance
resource "google_sql_database" "cloudsql_database" {
  name     = var.google_sql_database_name
  instance = google_sql_database_instance.cloudsql_instance.name
}

# Create a user in the CloudSQL database with a randomly generated password
resource "random_password" "database_password" {
  length  = var.random_password_length
  special = var.random_password_special
}

resource "google_sql_user" "cloudsql_user" {
  name     = var.google_sql_user
  instance = google_sql_database_instance.cloudsql_instance.name
  password = random_password.database_password.result
}
# Create a Service Account
resource "google_service_account" "my_service_account" {
  account_id   = var.google_service_account_account_id
  display_name = var.google_service_account_display_name
}

resource "google_project_iam_binding" "logging_admin_binding" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer_binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

# Resource to create instance
# resource "google_compute_instance" "vpc_instance" {
#   name         = var.custom_image_instance_name
#   machine_type = var.custom_image_instance_machine_type
#   zone         = var.custom_image_instance_zone
#   boot_disk {
#     initialize_params {
#       image = var.instance_name
#       size  = var.custom_image_instance_bootdisk_size
#       type  = var.custom_image_instance_bootdisk_type
#     }
#   }
#   network_interface {
#     network    = google_compute_network.my_vpc.self_link
#     subnetwork = google_compute_subnetwork.webapp_subnet.self_link
#     access_config {
#     }
#   }
#   tags = var.network_tag

#   depends_on = [
#     google_sql_database_instance.cloudsql_instance,
#     google_sql_user.cloudsql_user,
#     google_compute_address.endpointip,
#     google_service_account.my_service_account,
#     google_project_iam_binding.monitoring_metric_writer_binding,
#     google_project_iam_binding.logging_admin_binding
#   ]

#   metadata_startup_script = <<-EOF

#       #!/bin/bash
#       ENV_FILE="/opt/webapp/.env"

#       # Check if the .env file already exists
#       if [ ! -f "$ENV_FILE" ]; then

#         echo "HOST=${google_compute_address.endpointip.address}" > /opt/webapp/.env
#         echo "DB=${google_sql_database.cloudsql_database.name}" >> /opt/webapp/.env
#         echo "DB_USER=${google_sql_user.cloudsql_user.name}" >> /opt/webapp/.env
#         echo "DB_PASSWORD=${google_sql_user.cloudsql_user.password}" >> /opt/webapp/.env
#         echo "DIALECT=mysql" >> /opt/webapp/.env
#         echo "LOGPATH=/var/log/webapp/myapp.log" >> /opt/webapp/.env

#         #sudo ./opt/webapp/packer-config/configure_systemd.sh

#         echo "Environment variables written to $ENV_FILE"
#       else
#           echo "The file $ENV_FILE already exists. Skipping writing environment variables."
#       fi

#       sudo ./opt/webapp/packer-config/configure_systemd.sh

#       EOF

#   # resource "google_compute_instance" "vpc_instance" {
#   // Existing configuration for the instance...

#   # Attach the service account
#   service_account {
#     email  = google_service_account.my_service_account.email
#     scopes = ["cloud-platform"]
#   }

# }

# Add or update A record in Cloud DNS zone
resource "google_dns_record_set" "webapp_dns_record" {
  name = var.domain_name
  type = var.webapp_dns_record_type
  ttl  = var.ttl

  managed_zone = var.dns_managed_zone

  # The IP address of your VM instance
  rrdatas = [google_compute_global_forwarding_rule.lb_forwarding_rule.ip_address]
}

resource "google_compute_firewall" "vpc1_firewall" {
  name    = var.firewall_name
  network = google_compute_network.my_vpc.self_link
  #priority = 700

  allow {
    protocol = var.protocol_http
    ports    = var.ports_http
  }

  # Restrict the firewall to allow traffic only from specific IP addresses and ranges
  source_ranges = [google_compute_global_forwarding_rule.lb_forwarding_rule.ip_address, "35.191.0.0/16", "130.211.0.0/22"]

  target_tags = var.target_tags_http
}


# Resource to create Pub/Sub topic
resource "google_pubsub_topic" "example_topic" {
  name = var.topic_name
}

# Resource to create Pub/Sub subscription
resource "google_pubsub_subscription" "example_subscription" {
  name  = var.subscription_name
  topic = google_pubsub_topic.example_topic.name

}

# Grant the necessary permissions to the service account
resource "google_project_iam_binding" "cloud_function_iam_binding" {
  project = var.project_id
  role    = var.cloud_function_invoker_role

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}


//Create Cloud Function
resource "google_cloudfunctions_function" "example_function" {
  name                  = var.function_name
  runtime               = var.runtime
  entry_point           = var.entry_point
  source_archive_bucket = var.source_archive_bucket
  source_archive_object = var.source_archive_object

  event_trigger {
    event_type = var.function_event_trigger_event_type
    resource   = google_pubsub_topic.example_topic.name
  }

  available_memory_mb = 256
  timeout             = "60"

  environment_variables = {
    BUCKET_NAME     = var.bucket_name
    TOPIC_NAME      = google_pubsub_topic.example_topic.name
    DB              = var.google_sql_database_name
    DB_USER         = google_sql_user.cloudsql_user.name
    DB_PASSWORD     = random_password.database_password.result
    HOST            = google_compute_address.endpointip.address
    DIALECT         = "mysql"
    MAILGUN_API_KEY = var.mailgun_api
    MAILGUN_DOMAIN  = var.mailgun_domain
    MAIL_SENDER     = var.mail_sender
    BASE_URL        = var.base_url
  }

  service_account_email = google_service_account.my_service_account.email
  vpc_connector         = google_vpc_access_connector.cloud_function_connector.name
}


# resource "google_project_iam_binding" "topic_publisher_binding" {
#   project = var.project_id
#   role    = var.pubsub_role

#   members = [
#     "serviceAccount:${google_service_account.my_service_account.email}"
#   ]
# }

# Grant the necessary permissions to the service account used by Cloud Functions
resource "google_project_iam_binding" "cloud_function_token_creator_binding" {
  project = var.project_id
  role    = var.iam_service_account_token_role

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

resource "google_vpc_access_connector" "cloud_function_connector" {
  name          = var.vpc_connector_name
  network       = google_compute_network.my_vpc.self_link
  ip_cidr_range = var.ip_cidr_range
}

resource "google_project_iam_binding" "cloudsql_client_binding" {
  project = var.project_id
  role    = var.cloud_sql_client_role

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

resource "google_pubsub_topic_iam_binding" "topic_iam_binding" {
  topic = google_pubsub_topic.example_topic.name
  role  = var.google_pubsub_topic_iam_binding_topic_iam_binding_role
  members = [
    "serviceAccount:${google_service_account.my_service_account.email}",
  ]
}

resource "google_project_iam_binding" "disk_admin_binding" {
  project = var.project_id
  role    = "roles/compute.admin"

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

resource "google_compute_region_instance_template" "instance_template" {
  name        = var.template_name
  description = "This template is used to create app server instances."

  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  //can_ip_forward       = true

  disk {
    source_image = var.instance_name
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_crypto_key.id
    }
  }

  network_interface {
    network    = google_compute_network.my_vpc.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
    }

  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      ENV_FILE="/opt/webapp/.env"

      if [ ! -f "$ENV_FILE" ]; then
        echo "HOST=${google_compute_address.endpointip.address}" > /opt/webapp/.env
        echo "DB=${google_sql_database.cloudsql_database.name}" >> /opt/webapp/.env
        echo "DB_USER=${google_sql_user.cloudsql_user.name}" >> /opt/webapp/.env
        echo "DB_PASSWORD=${google_sql_user.cloudsql_user.password}" >> /opt/webapp/.env
        echo "DIALECT=mysql" >> /opt/webapp/.env
        echo "LOGPATH=/var/log/webapp/myapp.log" >> /opt/webapp/.env
        echo "Environment variables written to $ENV_FILE"
      else
        echo "The file $ENV_FILE already exists. Skipping writing environment variables."
      fi

      sudo ./opt/webapp/packer-config/configure_systemd.sh
    EOF
  }

  service_account {
    email  = google_service_account.my_service_account.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_sql_database_instance.cloudsql_instance,
    google_sql_user.cloudsql_user,
    google_compute_address.endpointip,
    google_service_account.my_service_account,
    google_project_iam_binding.monitoring_metric_writer_binding,
    google_project_iam_binding.logging_admin_binding
  ]
  tags = var.target_tags_http

}


# data "google_compute_image" "my_image" {
#   project = var.project_id
#   name    = var.instance_name
# }

resource "google_compute_region_autoscaler" "autoscalar" {
  name   = var.autoscaler_name
  region = var.autoscalar_region
  target = google_compute_region_instance_group_manager.appserver.self_link

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_target_utilization
    }
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = var.health_check_name
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    request_path = var.request_path
    port         = var.port
    port_name    = var.port_name
  }
}

resource "google_compute_region_instance_group_manager" "appserver" {
  name = var.instance_group_manager_name

  base_instance_name        = var.base_instance_name
  region                    = var.instance_group_manager_region
  distribution_policy_zones = var.distribution_policy_zones

  version {
    instance_template = google_compute_region_instance_template.instance_template.self_link
  }

  named_port {
    name = var.named_port_name
    port = var.named_port_port
  }

  instance_lifecycle_policy {
    //force_update_on_repair = "YES"
    //default_action_on_failure = var.action_on_failure
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = var.auto_healing_policies_initial_delay_sec
  }
  depends_on = [google_compute_region_instance_template.instance_template, google_compute_health_check.autohealing]

}
# ---------------------------------------------

resource "google_compute_managed_ssl_certificate" "lb_ssl_certificate" {
  name = var.ssl_certificate_name
  managed {
    domains = var.ssl_certificate_domains
  }
}

resource "google_compute_target_https_proxy" "lb_target_proxy" {
  name    = var.google_compute_target_https_proxy_lb_target_proxy
  url_map = google_compute_url_map.lb_url_map.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_ssl_certificate.id
  ]
}

resource "google_compute_url_map" "lb_url_map" {
  name            = var.lb-url-map
  default_service = google_compute_backend_service.lb_backend_service.self_link
}

resource "google_compute_backend_service" "lb_backend_service" {
  name                  = var.backend_service_name
  load_balancing_scheme = var.load_balancing_scheme
  health_checks         = [google_compute_health_check.lb_health_check.self_link]
  protocol              = var.backend_protocol
  port_name             = var.backend_port_name

  backend {
    group = google_compute_region_instance_group_manager.appserver.instance_group
  }
}

# Configure health check for the backend service
resource "google_compute_health_check" "lb_health_check" {
  name               = var.health_check_name_1
  check_interval_sec = var.check_interval_sec_1
  timeout_sec        = var.timeout_sec_1
  http_health_check {
    port         = var.health_check_port_1
    request_path = var.health_check_request_path
  }
}


# Define a global address for the load balancer
# resource "google_compute_global_address" "lb_ip" {
#   project = var.project_id
#   name    = "lb-ip"
# }

# Define a forwarding rule to forward traffic to the backend service
resource "google_compute_global_forwarding_rule" "lb_forwarding_rule" {
  name       = var.forwarding_rule_name
  target     = google_compute_target_https_proxy.lb_target_proxy.self_link
  port_range = var.forwarding_rule_port_range
  //ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = var.load_balancing_scheme_2
  ip_protocol           = var.ip_protocol
}

resource "google_kms_key_ring" "my_key_ring" {
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "storage_crypto_key" {
  name            = var.storage_crypto_key_name
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = var.storage_rotation_period

  lifecycle {
    prevent_destroy = false
  }
}


resource "google_storage_bucket" "my_bucket" {
  name          = var.my-bucket_name
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_crypto_key.id
  }

  depends_on = [
    google_service_account.my_service_account,
    //google_project_iam_binding.storage_admin_binding,
    google_kms_crypto_key.storage_crypto_key,
    google_kms_crypto_key_iam_binding.storage_crypto_key_binding
  ]
}

resource "google_storage_bucket_object" "example_object" {
  name   = var.my_object_name
  bucket = google_storage_bucket.my_bucket.name
  source = var.my_object_source
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_binding" "storage_crypto_key_binding" {
  crypto_key_id = google_kms_crypto_key.storage_crypto_key.id
  role          = var.iam_role

  members = ["serviceAccount:service-567928947423@gs-project-accounts.iam.gserviceaccount.com"]
}


resource "google_kms_crypto_key" "vm_crypto_key" {
  name            = var.vm_crypto_key_name
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = var.vm_rotation_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_template" {
  crypto_key_id = google_kms_crypto_key.vm_crypto_key.id
  role          = var.iam_role
  members       = ["serviceAccount:service-567928947423@compute-system.iam.gserviceaccount.com"]
  depends_on    = [google_kms_crypto_key.vm_crypto_key]
}

resource "google_kms_crypto_key" "cloudsql_crypto_key" {
  name            = var.cloudsql_crypto_key_name
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = var.cloudsql_rotation_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  project  = var.project_id
  service  = var.service_name
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_sql" {
  crypto_key_id = google_kms_crypto_key.cloudsql_crypto_key.id
  role          = var.iam_role
  members       = ["serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}"]
  depends_on    = [google_kms_crypto_key.cloudsql_crypto_key]
}
