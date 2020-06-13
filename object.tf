// Creating object in S3 bucket
resource "aws_s3_bucket_object" "s3_object"{
	bucket = aws_s3_bucket.s3_bucket.id
	acl = "public-read"
	key = "gun.jpg"
	force_destroy = true
	source = "C:/gun.jpg"
	etag = filemd5("C:/gun.jpg")
}

output "object"{
	value = aws_s3_bucket_object.s3_object.key
}
