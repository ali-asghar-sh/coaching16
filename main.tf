
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
      },
    ],
  })
}

#Retrieve URL lambda function 
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "retrieve_url_lambda" {
  filename         = "retrieve_lambda.zip"
  function_name    = "retrieve-url-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "retrieve-url-lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("retrieve_lambda.zip")


  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      REGION_AWS = "ap-southeast-1"
      DB_NAME     = var.db_name   ####Need to update dynamodb table name in variable.tf
    }
  }
}

#Create URL lambda Function
resource "aws_lambda_function" "create_url_lambda" {
  filename         = "create_lambda.zip"
  function_name    = "create-url-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "create-url-lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("create_lambda.zip")

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      APP_URL    = "https://short.ly"
      MIN_CHAR   = "5"
      MAX_CHAR   = "8"
      REGION_AWS = "ap-southeast-1"
      DB_NAME    = var.db_name       #Need to update Dynamodb Table name in variable.tf
    }
  }
}

#Creating the IAM role for create lambda function
resource "aws_iam_role" "create_lambda_exec" {
  name = "create_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "create_lambda_policy" {
  name = "create_lambda_policy"
  role = aws_iam_role.create_lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ],
        Resource = "*"  # Replace with specific DynamoDB ARN for tighter security
      },
      {
        Effect = "Allow",
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        Resource = "*"
      }
    ]
  })
}


#Creating IAM role for retrieve URL lambda
resource "aws_iam_role" "retrieve_lambda_exec" {
  name = "retrieve_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "retrieve_lambda_policy" {
  name = "retrieve_lambda_policy"
  role = aws_iam_role.retrieve_lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "*"  # Replace with specific DynamoDB ARN
      },
      {
        Effect = "Allow",
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        Resource = "*"
      }
    ]
  })
}