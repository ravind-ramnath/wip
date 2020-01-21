output "DB Endpoint" {
        value = "${aws_db_instance.wordpressdb.address}"
}

output "ECS Cluster" {
        value = "${aws_ecs_cluster.wp-cluster.name}"
}

output "WordPress Public Endpoint - Required for Service Call" {
  value = "${aws_elb.elb.dns_name}"
}

output "Wordpress Create Post API Service Enpoint" {
  value = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.aws_region}.amazonaws.com/tvnz/createPost"
}

output "Bastion Public IP" {
  value = "${aws_instance.bastion.public_ip}"
}

output "Private IP GW" {
        value = "${aws_nat_gateway.nat_gw.*.private_ip}"
}

output "Public IP GW" {
        value = "${aws_nat_gateway.nat_gw.*.public_ip}"
}

output "Bastion SSH Private Key (Demo purposes only)" {
  value = "${tls_private_key.bastion-host.private_key_pem}"
}

output "ECS SSH Private Key (Demo purposes only)" {
  value = "${tls_private_key.ecs_key_pair.private_key_pem}"
}