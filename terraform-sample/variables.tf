variable "location" {
  description = "The location for resource deployment"
  type        = string

  default = "uksouth"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map

  default = {
    application = "github-actions-demo"
    environment = "development"
    owner       = "lufussel"
    buildagent  = "github-actions"
  }
}

variable "env" {
  description = "Environment prefix for resource naming."
  type        = string

  default = "dev"
}

variable "app_name" {
  description = "Short name of app for resource naming."
  type        = string

  default = "ghademo"
}
