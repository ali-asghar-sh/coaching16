
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
