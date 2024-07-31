provider "aws" { 
region = "us-east-1"
}


variable "keyname" {
 type = string
}

terraform {
  backend "s3" {
      region = "us-east-1"
     bucket = "nts18s3tf"
     dynamodb_table = "tfnts18"
     key = "test19992854549089089911.tfstate"
    
  }
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits = 4096
}


resource "aws_key_pair" "tf-key-pair" {
key_name = var.keyname
public_key = tls_private_key.rsa.public_key_openssh
}


resource "local_file" "tf-key" {
content = tls_private_key.rsa.private_key_pem
filename = var.keyname
}


resource "aws_instance" "web-server" {
 ami      = "ami-04a81a99f5ec58529"
 instance_type = "t2.micro"
 key_name   = var.keyname



 provisioner "remote-exec" {
 inline = [
"sudo add-apt-repository -y -s "deb http://archive.ubuntu.com/ubuntu/ "",
"sudo apt-get update",
 "sudo apt-get update",
 "sudo apt install -y tomcat9",
 "sudo chmod -R 777 /var/lib/tomcat9/webapps/",
 "sudo rm -rf /var/lib/tomcat9/webapps/ROOT"   
 ]
 }

provisioner "file" {
source   =    "../target/japp19.war"
destination = "/var/lib/tomcat9/webapps/ROOT.war"
}



 connection {



  user    = "ubuntu"



  private_key = "${file(local_file.tf-key.filename)}"



   host = "${aws_instance.web-server.public_ip}"



 }



}



output "pub_ip" {

  value = aws_instance.web-server.public_ip

}
