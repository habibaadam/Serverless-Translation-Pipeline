variable "region" {
  type    = string
  default = "us-east-1"
}

variable "request_bucket_name" {
  type    = string
  default = "habi-request-bucket"
}

variable "response_bucket_name" {
  type    = string
  default = "habi-response-bucket"
}

variable "lifecycle_expiration_days" {
  type    = number
  default = 30
}

variable "default_target_lang" {
  type    = string
  default = "fr"
}