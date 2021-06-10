# Designate a cloud provider, region, and credentials
provider "aws" {
  region = "eu-central-1"
}

# Provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "udacity_t2_micro" {
  ami           = "ami-043097594a7df80ec"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-027c2843f32e19097"]
  subnet_id = "subnet-010432fe9ea15cd45"
  count         = 4
  tags = {
    Name = "Udacity T2"
    Enviroment  = "Dev"
  }
}


# Provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "udacity_m4_large" {
  ami           = "ami-043097594a7df80ec"
  instance_type = "m4.large"
  vpc_security_group_ids = ["sg-027c2843f32e19097"]
  subnet_id = "subnet-010432fe9ea15cd45"
  count         = 2

  tags = {
    Name = "Udacity M4"
    Enviroment  = "Dev"
  }
}