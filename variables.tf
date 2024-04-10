variable "project_id" {
  description = "The ID of the GCP project"
}

variable "region" {
  description = "The region for the resources"
}

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "auto_create_subnetworks" {
  description = "Boolean value to not create subnetworks"
}

variable "delete_default_routes_on_create" {
  description = "Boolean value to delete default routes on create"
}

variable "webapp_subnet_name" {
  description = "Name of the webapp subnet"
}

variable "db_subnet_name" {
  description = "Name of the db subnet"
}

variable "webapp_subnet_cidr" {
  description = "CIDR range for the webapp subnet"
}

variable "db_subnet_cidr" {
  description = "CIDR range for the db subnet"
}

variable "vpc_route_name" {
  description = "Name of the vpc route"
}

variable "routing_mode" {
  description = "Name of the routing mode"
}

variable "route_range" {
  description = "Range for the webapp subnet route"
}

variable "next_hop_gateway" {
  description = "value for next_hop_gateway"
}

variable "firewall_http" {
  description = "Name of the firewall"
}

variable "protocol_http" {
  description = "Protocol for the firewall rule"
}

variable "ports_http" {
  description = "List of ports to allow traffic"
}

variable "source_ranges_http" {
  description = "List of source IP ranges to allow traffic from"
}

variable "target_tags_http" {
  description = "List of target tags to apply the firewall rule to"
}

variable "source_ranges_ssh" {
  description = "List of source IP ranges to deny traffic from"
}

variable "target_tags_ssh" {
  description = "List of target tags to deny the firewall rule to"
}

variable "protocol_ssh" {
  description = "Protocol for the firewall rule"
}

variable "custom_image_instance_name" {
  description = "Name of the custom image instance name"
}

variable "custom_image_instance_machine_type" {
  description = "Name of the custom image instance machine type"
}

variable "custom_image_instance_zone" {
  description = "Name of the custom image instance zone"
}

variable "custom_image_instance_bootdisk_size" {
  description = "Size of the custom image instance bootdisk"
}

variable "custom_image_instance_bootdisk_type" {
  description = "Type of the custom image instance bootdisk"
}

variable "firewall_ssh" {
  description = "Name of the deny ssh firewall"
}

variable "network_tag" {
  description = "Name of the network tag"
}

variable "instance_name" {
  description = "Name of the instance"
}

variable "priority_allow" {
  description = "Priority allow"
}
variable "priority_deny" {
  description = "Priority deny"
}

variable "ports_ssh" {
  description = "IP protocol for the forwarding rule"
}

variable "cloudsql_instance_name" {
  description = "cloudsql instance name"
}
variable "delete_protection" {
  description = "delete protection"
}

variable "database_version" {
  description = "database_version"
}

variable "google_sql_database_disk_type" {
  description = "google sql database disk type"
}

variable "google_sql_database_disk_size" {
  description = "google sql database disk size"
}

variable "google_sql_database_instance_tier" {
  description = "google sql database instance tier"
}

variable "google_sql_database_instance_availability_type" {
  description = "google sql database instance availability type"
}

variable "backup_configuration_enabled" {
  description = "backup configuration enabled"
}

variable "backup_configuration_binary_log_enabled" {
  description = "backup configuration_binary_log_enabled"
}

variable "google_compute_global_address_prefix_length" {
  description = "prefix_length"
}

variable "google_compute_address_endpoint" {
  description = "google compute address endpoint"
}

variable "google_compute_address_type" {
  description = "google compute address endpoint"
}

variable "psc_config_psc_enabled" {
  description = "psc config psc enabled"
}

variable "psc_config_ipv4_enabled" {
  description = "psc config ipv4 enabled"
}

variable "google_compute_global_address_name" {
  description = "google compute global address name"
}

variable "google_compute_global_address_type" {
  description = "google compute global address type"
}

variable "google_compute_global_address_purpose" {
  description = "google compute global address purpose"
}

variable "google_sql_database_name" {
  description = "google_sql_database_name"
}

variable "random_password_length" {
  description = "random_password_length"
}

variable "random_password_special" {
  description = "random_password_special"
}

variable "google_sql_user" {
  description = "google_sql_user"
}

variable "google_service_networking_connection_service" {
  description = "google_service_networking_connection_service"
}
variable "dns_managed_zone" {
  description = "Public zone for managing the dns"
}

variable "domain_name" {
  description = "Domain name"
}

variable "ttl" {
  description = "ttl"
}

variable "webapp_dns_record_type" {
  description = "type"
}

variable "google_service_account_account_id" {
  description = "google_service_account_account_id"
}

variable "google_service_account_display_name" {
  description = "google_service_account_display_name"
}
variable "topic_name" {
  description = "The name of the Pub/Sub topic"
}

variable "subscription_name" {
  description = "The name of the Pub/Sub subscription"
}

variable "service_account_email" {
  description = "The email address of the service account"
}

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
}

variable "source_archive_bucket" {
  description = "The name of the Cloud Storage bucket where the source code archive is stored"
}

variable "source_archive_object" {
  description = "The name of the Cloud Storage object for the source code archive"
}

variable "function_name" {
  description = "The name of the Cloud Function"
}

variable "runtime" {
  description = "The runtime environment for the Cloud Function"
}

variable "entry_point" {
  description = "The entry point for the Cloud Function"
}

variable "pubsub_role" {
  description = "The role for Pub/Sub publisher"
}

variable "iam_service_account_token_role" {
  description = "The role for IAM service account token creator"
}

# variable "cloud_function_iam_role" {
#   description = "The role for Cloud Functions invoker"
# }

variable "google_pubsub_topic_iam_binding_topic_iam_binding_role" {
  description = "The role for Cloud Functions invoker"
}

variable "vpc_connector_name" {
  description = "The name of the VPC connector"
}

variable "ip_cidr_range" {
  description = "The IP CIDR range for the VPC connector"
}

variable "cloud_sql_client_role" {
  description = "The cloud sql client role"
}

variable "cloud_function_invoker_role" {
  description = "IAM role for Cloud Functions"
}

variable "function_event_trigger_event_type" {
  description = "Event type for the Cloud Function event trigger"
}

variable "template_name" {
  description = "Description for the instance template"
}

variable "template_description" {
  description = "Description for the instance template"
}

variable "machine_type" {
  description = "Machine type for the instance"
}

variable "firewall_name" {
  description = "vpc1-firewall"
}

variable "disk_size_gb" {
  description = "Size of the disk in GB"
}

variable "disk_type" {
  description = "Type of disk"
}

# variable "service_account_scopes" {
#   description = "Scopes for the service account"
#}

# variable "depends_on_resources" {
#   description = "Resources that this template depends on"
# }

# variable "firewall_source_ranges" {
#   description = "Tags for the instance"
# }

variable "autoscaler_name" {
  description = "The name of the autoscaler"
}

variable "autoscalar_region" {
  description = "The region for the autoscaler"
}

# variable "target_instance_group_manager" {
#   description = "The self link of the target instance group manager"
# }

variable "max_replicas" {
  description = "The maximum number of replicas"
}

variable "min_replicas" {
  description = "The minimum number of replicas"
}

variable "cooldown_period" {
  description = "The cooldown period in seconds"
}

variable "cpu_target_utilization" {
  description = "The target CPU utilization"
}

variable "health_check_name" {
  description = "The name of the health check"
}

variable "check_interval_sec" {
  description = "The interval between health checks in seconds"
}

variable "timeout_sec" {
  description = "The timeout for each health check attempt in seconds"
}

variable "healthy_threshold" {
  description = "The number of consecutive successful health checks required to mark the backend as healthy"
}

variable "unhealthy_threshold" {
  description = "The number of consecutive failed health checks required to mark the backend as unhealthy"
}

variable "request_path" {
  description = "The path to use for the HTTP health check request"
}

variable "port" {
  description = "The port on the instance to which this health check sends traffic"
}

variable "port_name" {
  description = "The name of the port to which this health check sends traffic"
}

variable "instance_group_manager_name" {
  description = "The name of the instance group manager"
}

variable "base_instance_name" {
  description = "The base instance name"
}

variable "instance_group_manager_region" {
  description = "The region where the instance group manager is located"
}

variable "distribution_policy_zones" {
  description = "The zones to distribute instances for the instance group manager"
}

variable "named_port_name" {
  description = "named port name"
}

variable "named_port_port" {
  description = "named port port"
}

variable "auto_healing_policies_initial_delay_sec" {
  description = "named port port"
}

variable "ssl_certificate_name" {
  description = "The name of the SSL certificate"
}

variable "ssl_certificate_domains" {
  description = "The list of domains for the SSL certificate"
}

variable "google_compute_target_https_proxy_lb_target_proxy" {
  description = "named port port"
}
variable "lb-url-map" {
  description = "lb-url-map"
}

variable "backend_service_name" {
  description = "The name of the backend service"
}

variable "load_balancing_scheme" {
  description = "The load balancing scheme for the backend service"
}

# variable "health_check_links" {
#   description = "List of health check links for the backend service"
# }

variable "backend_protocol" {
  description = "The protocol for the backend service"
}

variable "backend_port_name" {
  description = "The port name for the backend service"
}

variable "health_check_name_1" {
  description = "Name of the health check"
}

variable "check_interval_sec_1" {
  description = "Interval between health checks in seconds"
}

variable "timeout_sec_1" {
  description = "Timeout for each health check request in seconds"
}

variable "health_check_port_1" {
  description = "Port to use for the health check"
}

variable "health_check_request_path" {
  description = "The path to use for the health check request"
}
variable "forwarding_rule_name" {
  description = "Name of the forwarding rule"
}

variable "forwarding_rule_port_range" {
  description = "Port range for the forwarding rule"
}

variable "load_balancing_scheme_2" {
  description = "Load balancing scheme for the forwarding rule"
}

variable "ip_protocol" {
  description = "IP protocol for the forwarding rule"
}

variable "action_on_failure" {
  description = "IP protocol for the forwarding rule"
}
variable "mailgun_domain" {
  description = "The domain used for Mailgun"
}

variable "mail_sender" {
  description = "The sender email address"
}

variable "base_url" {
  description = "The base URL"
}

variable "mailgun_api" {
  description = "The domain used for Mailgun"
}
variable "key_ring_name" {
  type = string
}

variable "storage_crypto_key_name" {
  type = string
}

variable "storage_rotation_period" {
  type = string
}

variable "my-bucket_name" {
  type = string
}

variable "bucket_location" {
  type = string
}

variable "my_object_name" {
  type = string
}

variable "my_object_source" {
  type = string
}

variable "iam_role" {
  type = string
}

variable "vm_crypto_key_name" {
  type    = string
}

variable "vm_rotation_period" {
  type    = string
}

variable "cloudsql_crypto_key_name" {
  type    = string
}

variable "cloudsql_rotation_period" {
  type    = string
}

variable "service_name" {
  type    = string
}

































