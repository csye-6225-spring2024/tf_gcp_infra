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

# Resource to create route for webapp subnet
resource "google_compute_route" "vpc_route" {
  name             = var.vpc_route_name
  network          = google_compute_network.my_vpc.self_link
  dest_range       = var.route_range
  next_hop_gateway = var.next_hop_gateway
}

# Resource to create firewall
resource "google_compute_firewall" "vpc_firewall" {
  name     = var.firewall_http
  network  = google_compute_network.my_vpc.self_link
  priority = var.priority_allow

  allow {
    protocol = var.protocol_http
    ports    = var.ports_http
  }

  source_ranges = var.source_ranges_http
  target_tags   = var.target_tags_http
}

# Resource to deny firewall
resource "google_compute_firewall" "deny-ssh" {
  name     = var.firewall_ssh
  network  = google_compute_network.my_vpc.self_link
  priority = var.priority_deny

  deny {
    protocol = var.protocol_ssh
  }

  source_ranges = var.source_ranges_ssh
  target_tags   = var.target_tags_ssh
}

# Create the CloudSQL instance
resource "google_sql_database_instance" "cloudsql_instance" {
  name                = var.cloudsql_instance_name
  deletion_protection = var.delete_protection
  region              = var.region
  database_version    = var.database_version

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
resource "google_compute_instance" "vpc_instance" {
  name         = var.custom_image_instance_name
  machine_type = var.custom_image_instance_machine_type
  zone         = var.custom_image_instance_zone
  boot_disk {
    initialize_params {
      image = var.instance_name
      size  = var.custom_image_instance_bootdisk_size
      type  = var.custom_image_instance_bootdisk_type
    }
  }
  network_interface {
    network    = google_compute_network.my_vpc.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
    }
  }
  tags = var.network_tag

  depends_on = [
    google_sql_database_instance.cloudsql_instance,
    google_sql_user.cloudsql_user,
    google_compute_address.endpointip,
    google_service_account.my_service_account,
    google_project_iam_binding.monitoring_metric_writer_binding,
    google_project_iam_binding.logging_admin_binding
  ]

  metadata_startup_script = <<-EOF
      
      #!/bin/bash
      ENV_FILE="/opt/webapp/.env"

      # Check if the .env file already exists
      if [ ! -f "$ENV_FILE" ]; then

        echo "HOST=${google_compute_address.endpointip.address}" > /opt/webapp/.env
        echo "DB=${google_sql_database.cloudsql_database.name}" >> /opt/webapp/.env
        echo "DB_USER=${google_sql_user.cloudsql_user.name}" >> /opt/webapp/.env
        echo "DB_PASSWORD=${google_sql_user.cloudsql_user.password}" >> /opt/webapp/.env
        echo "DIALECT=mysql" >> /opt/webapp/.env
        echo "LOGPATH=/var/log/webapp/myapp.log" >> /opt/webapp/.env

        #sudo ./opt/webapp/packer-config/configure_systemd.sh
        
        echo "Environment variables written to $ENV_FILE"
      else
          echo "The file $ENV_FILE already exists. Skipping writing environment variables."
      fi

      sudo ./opt/webapp/packer-config/configure_systemd.sh
      
      EOF

  # resource "google_compute_instance" "vpc_instance" {
  // Existing configuration for the instance...

  # Attach the service account
  service_account {
    email  = google_service_account.my_service_account.email
    scopes = ["cloud-platform"]
  }

}

# Add or update A record in Cloud DNS zone
resource "google_dns_record_set" "webapp_dns_record" {
  name = var.domain_name
  type = var.webapp_dns_record_type
  ttl  = var.ttl

  managed_zone = var.dns_managed_zone

  # The IP address of your VM instance
  rrdatas = [google_compute_instance.vpc_instance.network_interface.0.access_config.0.nat_ip]
}

# Resource to create Pub/Sub topic
resource "google_pubsub_topic" "example_topic" {
  name = var.topic_name
}

# Resource to create Pub/Sub subscription
# resource "google_pubsub_subscription" "example_subscription" {
#   name  = var.subscription_name
#   topic = google_pubsub_topic.example_topic.name

# }

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
    BUCKET_NAME = var.bucket_name
    TOPIC_NAME  = google_pubsub_topic.example_topic.name
    DB          = var.google_sql_database_name
    DB_USER     = google_sql_user.cloudsql_user.name
    DB_PASSWORD = random_password.database_password.result
    HOST        = google_compute_address.endpointip.address
    DIALECT     = "mysql"
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









