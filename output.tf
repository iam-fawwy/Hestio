#displaying the public IP for the public VM
output "EC2_1_IP" {
  value = aws_eip.HESTIO_EIP2.public_ip
}
#displaying the private IP for the private VM
output "EC2_2_PRIVATE_IP" {
  value = aws_instance.HESTIO_EC2_2.private_ip
}