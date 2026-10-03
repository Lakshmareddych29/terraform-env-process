variable "parameters" {
  description = "SSM parameters to create"

  type = map(object({
    name        = string
    description = optional(string)
    type        = optional(string, "String")
    value       = string
    tier        = optional(string, "Standard")
  }))
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}