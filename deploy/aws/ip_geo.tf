variable "ipgeo_url" {
  description = " get IP geo location"
  type        = string
  default     = "https://public.krazyminds.com"
}

# create /v1/api/ipgeo resouce
resource "aws_api_gateway_resource" "v1_api_ipgeo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1_api.id
  path_part   = "ipgeo"
}

# GET on /v1/api/ipgeo
resource "aws_api_gateway_method" "ipgeo" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.v1_api_ipgeo.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "ipgeo_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_ipgeo.id
  http_method = aws_api_gateway_method.ipgeo.http_method
  status_code = "200"
}


resource "aws_api_gateway_integration" "ipgeo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.v1_api_ipgeo.id
  http_method             = aws_api_gateway_method.ipgeo.http_method
  type                    = "HTTP"
  integration_http_method = "POST"
  uri                     = "${var.ipgeo_url}/ipinfo"

  request_templates = {
    "application/json" = <<EOF
    {
      "ip": "$context.identity.sourceIp"
    }
    EOF
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_integration_response" "ipgeo_integration_resp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.v1_api_ipgeo.id
  http_method = aws_api_gateway_method.ipgeo.http_method

  # Note: status_code has to be tied exactly as below, otherwise terraform apply fails.
  status_code = aws_api_gateway_method_response.ipgeo_resp.status_code
}