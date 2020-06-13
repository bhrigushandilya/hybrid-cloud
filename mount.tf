// Auto mount EBS volume to "/var/www/html" directory and downloadind code from github to "var/www/html"
resource "null_resource" "null1"{
	depends_on = [
		aws_volume_attachment.attach-vol,
	]
	
	connection{
		type = "ssh"
		user = "ec2-user"
		private_key = file("C:/Users/Bhrigu/.ssh/id_rsa")
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
