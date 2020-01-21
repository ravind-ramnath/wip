resource "aws_api_gateway_rest_api" "rest_api" {
  name = "Word Press Demo Api"
  description = "Lambda Function Console Testing"
}

resource "aws_api_gateway_resource" "WordPressApi" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  parent_id = "${aws_api_gateway_rest_api.rest_api.root_resource_id}"
  path_part = "createPost"
}

resource "aws_api_gateway_method" "CreatePost" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.WordPressApi.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "WordPressLambdaIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.WordPressApi.id}"
  http_method = "${aws_api_gateway_method.CreatePost.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${aws_lambda_function.post_function.function_name}/invocations"
  integration_http_method = "${aws_api_gateway_method.CreatePost.http_method}"
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.WordPressApi.id}"
  http_method = "${aws_api_gateway_method.CreatePost.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "lambda-post-reponse" {
  depends_on = ["aws_api_gateway_integration.WordPressLambdaIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  resource_id = "${aws_api_gateway_resource.WordPressApi.id}"
  http_method = "${aws_api_gateway_method.CreatePost.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
}
resource "aws_api_gateway_deployment" "lambda-api-deployment" {
  depends_on = ["aws_api_gateway_integration_response.lambda-post-reponse"]
  rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  stage_name = "tvnz"
}
