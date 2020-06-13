// Creating AWS Instance with key and security group we have created.
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
