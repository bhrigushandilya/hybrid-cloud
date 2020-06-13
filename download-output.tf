resource "null_resource" "null2"{
	provisioner "local-exec"{
		command = "chrome ${aws_cloudfront_distribution.s3_dist.domain_name}/${aws_s3_bucket_object.s3_object.key}"
	}
}
