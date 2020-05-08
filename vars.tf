variable "AWS_DEFAULT_REGION" { }

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

variable "AWS_ACCESS_KEY_ID" { }
variable "AWS_SECRET_KEY_ID" { }


