
variable "apigateway_stage" {
  description = "Stage for API Gateway Data Mapping Demo "
  type        = string
  default     = "dev"
}

variable "agify_url" {
  description = " agify url - given a name guess the age"
  type        = string
  default     = "https://api.agify.io"
}

variable "ipinfo_url" {
  description = " ipinfo url - given a IP find the location and other details"
  type        = string
  default     = "https://ipinfo.io"
}


output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.apigateway_deploy.invoke_url}${aws_api_gateway_stage.app_stage.stage_name}"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "APIGatewayDataMappingDemo"
  description = "API Gateway Data Mapping In Depth - Demo"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# create resource /v1
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "v1"
}

# create resource /v1/api
resource "aws_api_gateway_resource" "v1_api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "api"
}

# create resource /v1/api/agify
resource "aws_api_gateway_resource" "v1_api_agify" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1_api.id
  path_part   = "agify"
}

# create GET method on /v1/api/agify?n=string
resource "aws_api_gateway_method" "agify_name" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.v1_api_agify.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.n" = true
  }
}

resource "aws_api_gateway_method_response" "agify_name_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_agify.id
  http_method = aws_api_gateway_method.agify_name.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "agify_name_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.v1_api_agify.id
  http_method             = aws_api_gateway_method.agify_name.http_method
  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = var.agify_url

  request_parameters = {
    "integration.request.querystring.name" = "method.request.querystring.n"
  }
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration_response" "agify_name_integration_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_agify.id
  http_method = aws_api_gateway_method.agify_name.http_method

  # Note: status_code has to be tied exactly as below, otherwise terraform apply fails.
  status_code = aws_api_gateway_method_response.agify_name_resp.status_code
}

# create /v1/api/ipinfo resouce
resource "aws_api_gateway_resource" "v1_api_ipinfo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1_api.id
  path_part   = "ipinfo"
}

# create /v1/api/ipinfo/{ip} resouce
resource "aws_api_gateway_resource" "v1_api_ipinfo_ip" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1_api_ipinfo.id
  path_part   = "{ip}"
}

# GET on /v1/api/ipinfo/{ip}
resource "aws_api_gateway_method" "ipinfo_ip" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.v1_api_ipinfo_ip.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.ip" = true
  }
}

resource "aws_api_gateway_method_response" "ipinfo_ip_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_ipinfo_ip.id
  http_method = aws_api_gateway_method.ipinfo_ip.http_method
  status_code = "200"
}


resource "aws_api_gateway_integration" "ipinfo_ip_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.v1_api_ipinfo_ip.id
  http_method             = aws_api_gateway_method.ipinfo_ip.http_method
  type                    = "HTTP"
  integration_http_method = "GET"
  uri                     = "${var.ipinfo_url}/{ip}/geo"

  request_parameters = {
    "integration.request.path.ip" = "method.request.path.ip"
  }
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_integration_response" "ipinfo_ip_integration_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_ipinfo_ip.id
  http_method = aws_api_gateway_method.ipinfo_ip.http_method

  # Note: status_code has to be tied exactly as below, otherwise terraform apply fails.
  status_code = aws_api_gateway_method_response.ipinfo_ip_resp.status_code
}



resource "aws_api_gateway_deployment" "apigateway_deploy" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment:
  #
  # When the REST API configuration involves other Terraform resources
  # (aws_api_gateway_integration resource, etc.), the dependency setup
  # can be done with implicit resource references in the 'triggers' argument
  # or explicit resource references using the resource depends_on meta-argument.
  # The triggers argument should be preferred over 'depends_on', since depends_on
  # can only capture dependency ordering and will not cause the resource to
  # recreate (redeploy the REST API) with upstream configuration changes.

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.v1_api_agify.id,
      aws_api_gateway_method.agify_name.id,
      aws_api_gateway_method_response.agify_name_resp.id,
      aws_api_gateway_integration_response.agify_name_integration_resp.id,
      aws_api_gateway_integration.agify_name_integration.id,

      aws_api_gateway_resource.v1_api_ipinfo.id,
      aws_api_gateway_resource.v1_api_ipinfo_ip.id,
      aws_api_gateway_method_response.ipinfo_ip_resp.id,
      aws_api_gateway_integration_response.ipinfo_ip_integration_resp.id,
      aws_api_gateway_integration.ipinfo_ip_integration.id,
    ]))
  }

  # To minimize the downtime: create updated deployment before destroying existing one.
  lifecycle {
    create_before_destroy = true
  }

  # these resources must be created before deployment
  depends_on = [
    aws_api_gateway_integration.agify_name_integration
  ]
}

resource "aws_api_gateway_stage" "app_stage" {
  deployment_id = aws_api_gateway_deployment.apigateway_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.apigateway_stage
}


# create IAM role for lambda
resource "aws_iam_role" "apigateway_role" {
  name               = "DataMapAPIGatewayRole"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": ["apigateway.amazonaws.com"]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# allow API gateway to push logs to CloudWatch
resource "aws_api_gateway_account" "apigateway_account" {
  cloudwatch_role_arn = aws_iam_role.apigateway_role.arn
}

# attach cloudWatch policy to IAM role
resource "aws_iam_role_policy_attachment" "cloudwatch_log_policy" {
  role       = aws_iam_role.apigateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# enable all methods full request and response logs to cloudWatch
resource "aws_api_gateway_method_settings" "payapp_cloudwatch_logs" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.app_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true

    # this rate limiting applies to all methods in the stage_name
    throttling_rate_limit  = 500  # requests per second
    throttling_burst_limit = 1000 # Allows up to 1000 requests in a burst
  }
}