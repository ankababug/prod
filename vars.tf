variable "region" { 
   default= "ap-south-1"
}

variable "vpc-cidr" {
   default= "172.16.0.0/16"
}

variable "tenancy" {
   default= "default"
}

/*data "aws_availability_zones" "available" { 
     state= "available"
}*/
   
variable "sub-cidrs" {
    default= "172.16.1.0/24"
}

variable "access_key" { }
variable "secret_key" { }


