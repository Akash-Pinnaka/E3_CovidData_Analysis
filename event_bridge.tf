resource "aws_cloudwatch_event_rule" "github_data_scheduler" {
  name                = "github_data_scheduler"
  schedule_expression = "cron(0 9 ? * MON *)"
  force_destroy       = true

}

resource "aws_cloudwatch_event_target" "a" {
  arn       = aws_lambda_function.copyGitHubS3.arn
  rule      = aws_cloudwatch_event_rule.github_data_scheduler.name
  target_id = "copy_github_s3"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.copyGitHubS3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:us-east-1:992382386350:rule/github_data_scheduler"
}

resource "aws_cloudwatch_event_rule" "glue_job_scheduler" {
  name = "glue_job_scheduler"
  event_pattern = jsonencode({
    "source" : ["arn:aws:lambda:us-east-1:992382386350:function:copyGitHubS3"],
    "detail-type" : ["Lambda Function Execution Status Change"],
    "detail" : {
      "status" : ["success"]
    }
  })
  force_destroy = true
}

resource "aws_cloudwatch_event_target" "b" {
  arn       = aws_lambda_function.launchGlueJob.arn
  rule      = aws_cloudwatch_event_rule.glue_job_scheduler.name
  target_id = "launch_glue_job"
}

resource "aws_lambda_permission" "allow_cloudwatch_glue" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.launchGlueJob.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:us-east-1:992382386350:rule/glue_job_scheduler"
}