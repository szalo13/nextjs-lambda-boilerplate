resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = "${aws_api_gateway_rest_api.example_api.id}.execute-api.${var.region}.amazonaws.com"
    zone_id                = "ZLY8HYME6SFDD"
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
}