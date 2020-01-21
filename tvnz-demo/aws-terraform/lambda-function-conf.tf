resource "aws_iam_role" "lambda_function_role" {
  name = "api-lamda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "post_function" {
    filename = "../target/tvnz-demo-1.0-SNAPSHOT.jar"
    function_name = "tvnzDemo"
    description = "Lambda function to create post on Wordpress."
    depends_on = ["aws_iam_role.lambda_function_role"]
    role = "${aws_iam_role.lambda_function_role.arn}"
    runtime = "java8"
    timeout = "60"
    handler = "com.tvnz.App"
    memory_size = 512
    source_code_hash = "${base64sha256(file("../target/tvnz-demo-1.0-SNAPSHOT.jar"))}"

}

resource "aws_lambda_permission" "allow_api_gateway" {
    function_name = "${aws_lambda_function.post_function.function_name}"
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_integration.WordPressLambdaIntegration.integration_http_method}${aws_api_gateway_resource.WordPressApi.path}"
}
