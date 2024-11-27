terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}
terraform {
  backend "s3" {
    bucket = "lab-tf-gh"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
#proveedor de servicios 
provider "aws" {
  region = "us-east-1"
}
resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "lambda_api"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "lab-apirest-prod-oas30-apigateway.json"
      version = "1.0"
    }
  })

}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "lab-lambda" {
  filename      = "test.zip"
  function_name = "lab-lambda"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
}

