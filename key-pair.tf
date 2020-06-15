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
