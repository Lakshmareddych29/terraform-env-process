variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "security_groups" {
  description = "Security groups and their rules"

  type = map(object({
    name        = string
    description = string

    ingress_rules = list(object({
      description     = string
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
    }))

    egress_rules = list(object({
      description     = string
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
    }))
  }))
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}