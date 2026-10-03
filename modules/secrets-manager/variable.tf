variable "secrets" {
  description = "Secrets to create in AWS Secrets Manager"

  type = map(object({
    name        = string
    description = optional(string, "Managed by Terraform")

    secret_string = string

    recovery_window_in_days = optional(number, 7)
  }))
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)

  default = {}
}