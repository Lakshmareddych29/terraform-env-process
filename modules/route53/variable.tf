variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Route53 hosted zone domain"
  type        = string
}

variable "zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
}

variable "records" {
  description = "Route53 DNS records"

  type = map(object({
    name = string
    type = string

    alias = object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    })
  }))
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}