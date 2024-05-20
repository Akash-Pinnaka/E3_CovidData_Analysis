resource "aws_iam_role" "glue_lambda_exec" {
  name = "covid19_glue_exec_role"
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

resource "aws_iam_role_policy_attachment" "glue_lambda_basic_execution_attachment" {
  role       = aws_iam_role.glue_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "glue_Service_role_attachnmnt" {
  role       = aws_iam_role.glue_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "name" {
  name = "covid19_glue_lambda_policy"
  role = aws_iam_role.glue_lambda_exec.name
  
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
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

resource "aws_lambda_function" "launchGlueJob" {
  filename         = "launchGlueJob.zip"
  function_name    = "launchGlueJob"
  role             = aws_iam_role.glue_lambda_exec.arn
  handler          = "launchGlueJob.lambda_handler"
  source_code_hash = filebase64sha256("launchGlueJob.zip")
  runtime          = "python3.12"
  timeout          = 90
  memory_size      = 128
}
