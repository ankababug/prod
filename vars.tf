variable "region" { }

variable "vpc-cidr" {
   default= "10.0.0.0/16"
}

variable "tenancy" {
   default= "default"
}

/*data "aws_availability_zones" "available" { 
     state= "available"
}*/
   
variable "sub-cidrs" {
    default= "10.0.1.0/24"
}

variable "access_key" { }
variable "secret_key" { }


