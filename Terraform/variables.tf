variable "ami_id" {
  default = "ami-0521cb2d60cfbb1a6"
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


