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
resource "google_compute_global_address" "peer_address" {
  name          = var.google_compute_global_address_name
  address_type  = var.google_compute_global_address_type
  prefix_length = var.google_compute_global_address_prefix_length
  purpose       = var.google_compute_global_address_purpose
  network       = google_compute_network.my_vpc.id
}
resource "google_service_networking_connection" "private_connection" {
  network                 = google_compute_network.my_vpc.id
  service                 = var.google_service_networking_connection_service
  reserved_peering_ranges = [google_compute_global_address.peer_address.name]
}
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
    google_compute_address.endpointip
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

    #sudo ./opt/webapp/packer-config/configure_systemd.sh
    
    echo "Environment variables written to $ENV_FILE"
  else
      echo "The file $ENV_FILE already exists. Skipping writing environment variables."
  fi

  sudo ./opt/webapp/packer-config/configure_systemd.sh
  
  EOF
}


