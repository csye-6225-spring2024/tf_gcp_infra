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

variable "cloud_function_iam_role" {
  description = "The role for Cloud Functions invoker"
}

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



