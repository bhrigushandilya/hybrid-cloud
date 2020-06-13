// Creating EBS volume
resource "aws_ebs_volume" "volume1"{
	availability_zone = aws_instance.instance1.availability_zone
	size = "2"
	type = "gp2" 

	tags = {
		Name = "volume1"
	}
}
