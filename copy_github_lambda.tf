resource "aws_iam_role" "lambda_exec" {
  name = "covid19_lambda_exec_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.name
  name = "covid19_lambda_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::projectpro-covid19-test-data-akash7/*",
          "arn:aws:s3:::projectpro-covid19-test-data-akash7"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "events:PutEvents"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}



resource "aws_lambda_function" "copyGitHubS3" {
  filename         = "copyGithubS3.zip"
  function_name    = "copyGitHubS3"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "copyGithubS3.lambda_handler"
  source_code_hash = filebase64sha256("copyGithubS3.zip")
  runtime          = "python3.12"
  timeout          = 90
  memory_size      = 128
}
