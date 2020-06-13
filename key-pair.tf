// Creating key pair
resource "aws_key_pair" "key"{
	key_name = "key1"
	public_key = file("C:/Users/Bhrigu/.ssh/id_rsa.pub")
}
