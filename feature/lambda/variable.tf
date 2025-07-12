
##This is added to update the Dynamodb name so we can assign variable instead of hardcoding the name 

variable "db_name" {
  description = "Name of the DynamoDB table used by the Lambda functions"
  type        = string
}