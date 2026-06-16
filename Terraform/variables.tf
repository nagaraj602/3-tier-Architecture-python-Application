variable "ami_id" {
  default = "ami-080d2f9cbbab903ef"
}
variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  default     = "ASoYRxsAI9snyjZZWjG6"
}


