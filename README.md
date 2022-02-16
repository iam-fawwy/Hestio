# Hestio
Tech Task

We have two Linux VMs, one public and the other private.
An elastic IP is associated to the public VM because we want a single IP for the VM which means when the EC2 instance is stopped, we retain the IP address when it comes up again.
The private VM does not have a public Ip because we want a secure a VM which it can only be accessed through the public VM.
We have 2 security groups, frontend and backend. Frontend to SSH into the public VM and backend is accessible through the frontend.
For the public VM to have a access to the internet, port 80 is open for the ingress rule of the frontend security group.
For the private to have access to the internet, an elastic IP is and public subnet is associated to a NAT gateway. The NAT gateway is later associated to a private route table with the private subnet. With all these been done, the private VM will be able to have access to the internet.
A public route table is also created in which it is associated to a internet gateway created and the public subnet.
We have our public key associated to the both VMs, where we use our private key to SSH into the two VMs.
The private key is manually copied into the public VM.
To copy the private key we use scp - secure copy over ssh
we have our output as part of the files so we don’t need to go to the AWS console to get out ips
on the display, we have the eip of the public VM  and the  private ip of the private VM.
We use the public ip to SSH into the public VM and private IP to SSH into the private VM
