// Provider for terraform which is "AWS" in our case.
provider "aws"{
	region = "ap-south-1"
	profile = "Bhrigu"
}

// Creating security group
resource "aws_security_group" "group1"{
	name = "ssh http"
	ingress{
		from_port = "22"
		to_port = "22"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress{
		from_port = "80"
		to_port = "80"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress{
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

// Creating key pair
resource "tls_private_key" "key1"{
	algorithm = "RSA"
}

resource "aws_key_pair" "generate_key"{
	key_name = "key1"
	public_key = tls_private_key.key1.public_key_openssh
	depends_on = [
		tls_private_key.key1
	]
}

resource "local_file" "key_text"{
	content = tls_private_key.key1.private_key_pem
	filename = "key1.pem"
	depends_on = [
		tls_private_key.key1
	]
}

// Creating AWS Instance
resource "aws_instance" "instance1"{
	ami = "ami-0447a12f28fddb066"
	instance_type = "t2.micro"
	security_groups = [ "ssh http" ]
	key_name = "key1"
	user_data = file("C:/Linux World/ws/security-group/script1.sh")	
	root_block_device{
		volume_type = "gp2"
		volume_size = "8"
		delete_on_termination = true
	}

	tags = {
		Name = "ins-1"
	}
}

// Creating EBS volume
resource "aws_ebs_volume" "volume1"{
	availability_zone = aws_instance.instance1.availability_zone
	size = "2"
	type = "gp2" 

	tags = {
		Name = "volume1"
	}
}

// Attaching EBS volume to created AWS Instance
resource "aws_volume_attachment" "attach-vol"{
	device_name = "/dev/sdh"
	volume_id = aws_ebs_volume.volume1.id
	instance_id = aws_instance.instance1.id
	force_detach = true
}

// Auto mount EBS volume to "/var/www/html" directory 
resource "null_resource" "null1"{
	depends_on = [
		aws_volume_attachment.attach-vol,
	]
	
	connection{
		type = "ssh"
		user = "ec2-user"
		private_key = tls_private_key.key1.private_key_pem
		host = aws_instance.instance1.public_ip
	}
	provisioner "remote-exec"{
		inline = [
			"sudo mkfs.ext4 /dev/xvdh",
			"sudo mount /dev/xvdh /var/www/html",
			"sudo rm -rf /var/www/html/*",
			"sudo git clone https://github.com/bhrigushandilya/hybrid-cloud.git /var/www/html/",
		]
	}
}

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
	private_key = tls_private_key.key1.private_key_pem
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

resource "null_resource" "null2"{
	provisioner "local-exec"{
		command = "chrome ${aws_cloudfront_distribution.s3_dist.domain_name}/${aws_s3_bucket_object.s3_object.key}"
	}
}
