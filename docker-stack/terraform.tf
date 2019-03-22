provider "aws" {
    region = "us-east-2"
}

resource "ec2-instance" "phpipam-cloud" {
    ami = "ami-04b61a4d3b11cc8ea"
    instance_type = "t2.micro"
}
