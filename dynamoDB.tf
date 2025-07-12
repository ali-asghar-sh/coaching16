# main.tf

# Create the DynamoDB table for storing URL mappings
resource "aws_dynamodb_table" "url_store" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_id"

  # Define the primary key attribute
  attribute {
    name = "short_id"
    type = "S" # S for String
  }

  # Enable Time to Live (TTL) to automatically delete expired items
  # The lambda code sets a 'ttl' attribute for this purpose.
  ttl {
    enabled        = true
    attribute_name = "ttl"
  }

  tags = {
    Name      = "URL Shortener Table"
    Project   = "URL-Shortener"
    ManagedBy = "Terraform"
  }
}