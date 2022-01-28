variable "aws_profile" {
    type    = string
    default = "tawsif-doodle"
}
variable "cidr_block" {
    default = "10.0.0.0/16"
}
variable "subnet" {
    default = "10.0.0.0/24"
}
variable "instance_type" {
    type    = string
    default = "t4g.micro"
}
variable "aws_availability_zone" {
    type    = string
    default = "us-east-1a"
}