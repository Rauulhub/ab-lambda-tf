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

#policy lambda
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
#iam role lambda
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "lab-lambda" {
  filename      = "test.zip"
  function_name = "lab-lambda"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
}

resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "lambda_api"
  body = templatefile("./lab-apirest-prod-oas30-apigateway.json.json", {}) # Ruta al archivo JSON
}

# Crear un recurso de integración Lambda en API Gateway
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.ambda_api.root_resource_id
  http_method = aws_api_gateway_method.lambda_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# Crear un método para manejar las peticiones en la API
resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# Crear un permiso para que API Gateway invoque la Lambda
resource "aws_lambda_permission" "api_gw_invoke_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lab-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.lambda-api.execution_arn}/*/*"
}
# Crear una implementación de la API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id

  depends_on = [
    aws_api_gateway_method.lambda_method,
    aws_api_gateway_integration.lambda_integration,
  ]
}