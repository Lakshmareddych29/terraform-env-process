variable "repositories" {
  description = "ECR repositories to create"

  type = map(object({
    name                 = string
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")

    enable_lifecycle_policy = optional(bool, true)
    keep_image_count        = optional(number, 10)
  }))

  default = {}
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)

  default = {}
}