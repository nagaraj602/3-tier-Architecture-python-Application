variable "ami_id" {
  default = "ami-080d2f9cbbab903ef"    
# Above AMI id had the application setup already. If you have deleted this ami. Then create everything with amazon linux default ami: ami-0521cb2d60cfbb1a6  and 
# then install app and then replace the ami. After this, you need to run terraform apply command and before that, you need to terminate the existing instance.
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


