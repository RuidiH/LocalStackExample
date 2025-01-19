variable "allowed_ip" {
  type        = string
  description = "The IP address allowed to SSH/HTTP into the instance."
#   default     = "0.0.0.0" // or no default
}
