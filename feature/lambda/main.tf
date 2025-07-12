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


resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "retrieve_url_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "retrieve-url-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "retrieve-url-lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      REGION_AWS = "ap-southeast-1"
      DB_NAME     = "your-dynamodb-table-name"
    }
  }
}
