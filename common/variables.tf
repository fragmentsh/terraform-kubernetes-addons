variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "addons" {
  type    = any
  default = {}
}

variable "addon_defaults" {
  description = "Default values for addons"
  type        = any
  default     = {}
}

variable "create_default_priority_classes" {
  description = "Whether to create priority classes"
  type        = bool
  default     = false
}

variable "priority_classes" {
  description = "Customize priority classes"
  type        = any
  default     = {}
}
