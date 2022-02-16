#var for the public key
variable "path_to_public_key" {
  default     = "/Users/fawwy/Downloads/DevOps/Hestio/Hestio.pub"
  description = "path to public key"
}
#var for the AMI for thr VM
variable "ami" {
  default     = "ami-0ad8ecac8af5fc52b"
  description = "ami for VM"
}