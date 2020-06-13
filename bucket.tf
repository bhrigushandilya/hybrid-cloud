// Creating S3 bucket
resource "aws_s3_bucket" "s3_bucket"{
	force_destroy = true
	acl = "public-read"
	versioning{
		enabled = true
	}
	website{
		index_document = "gun.jpg"
	}
	tags = {
		Name = "bucket1"
	}
}

resource "aws_s3_bucket_public_access_block" "s3_acl" {
	bucket = aws_s3_bucket.s3_bucket.id
	block_public_acls = false
}

locals{
	s3_origin_id = "bhrigus3origin"
}

output "bucket_url"{
	value = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}
