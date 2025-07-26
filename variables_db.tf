# variables_db.tf

variable "dynamodb_table_name" {
  description = "DynamoDB table for the URL shortener."
  type        = string
  default     = "group2-url-shortener-table"
}