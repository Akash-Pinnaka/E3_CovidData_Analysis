resource "aws_s3_object" "upload_glue_script" {
  bucket = aws_s3_bucket.covid19_bucket.bucket
  key    = "GlueScripts/glue_job_script.py"
  source = "./glue_job_script.py"
}

resource "aws_iam_role" "glue_job_iam_role" {
  name = "covid19_glue_job_iam_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "glue.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_job_service_role_attachment" {
  role       = aws_iam_role.glue_job_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


resource "aws_iam_role_policy" "glue_job_events_policy" {
  name = "covid19_glue_job_policy"
  role = aws_iam_role.glue_job_iam_role.name
  
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_glue_job" "covid19_glue_job" {
  name         = "covid19-confirmed-test1"
  role_arn     = aws_iam_role.glue_job_iam_role.arn
  number_of_workers="2"
  worker_type = "G.1X"

  command {
    name            = "glueetl"
    python_version = "3"
    script_location = "s3://projectpro-covid19-test-data-akash7/GlueScripts/glue_job_script.py"
  }
  
}
