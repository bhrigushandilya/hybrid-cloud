// Creating CloudFront
resource "aws_cloudfront_distribution" "s3_dist"{
	origin{
		domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
		origin_id = "$(local.s3_origin_id)"
}
enabled = true
is_ipv6_enabled = true

default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "$(local.s3_origin_id)"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
}

ordered_cache_behavior{
	path_pattern = "*"
	allowed_methods = ["GET", "HEAD"]
	cached_methods = ["GET", "HEAD"]
	target_origin_id = "$(local.s3_origin_id)"
	forwarded_values{
		query_string = false
		cookies{
			forward = "none"
		}
	}
	viewer_protocol_policy = "redirect-to-https"
	min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
    compress = true
}
restrictions {
	geo_restriction {
    	restriction_type = "whitelist"
    	locations = ["IN"]
    }
  }
viewer_certificate {
	cloudfront_default_certificate = true
  }

connection{
		type = "ssh"
		user = "ec2-user"
		private_key = file("C:/Users/Bhrigu/.ssh/id_rsa")
		host = aws_instance.instance1.public_ip
	}
provisioner "remote-exec"{
	inline = [
		"sudo su << EOF",
		"echo \"<img src='http://${aws_cloudfront_distribution.s3_dist.domain_name}/${aws_s3_bucket_object.s3_object.key}' height='400px' width='400px'/>\" >> /var/www/html/index.html",
		"EOF"
	]
}
}

output "o3"{
	value = aws_cloudfront_distribution.s3_dist.domain_name
}
