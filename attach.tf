// Attaching EBS volume to created AWS Instance
resource "aws_volume_attachment" "attach-vol"{
	device_name = "/dev/sdh"
	volume_id = aws_ebs_volume.volume1.id
	instance_id = aws_instance.instance1.id
	force_detach = true
}
