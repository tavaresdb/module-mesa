// DOC utilizada como referência: https://developer.hashicorp.com/terraform/language/values/variables

variable "instances" {
    type          = map(object({
    instance_type = string
    tag_name      = string
  }))
  description = "Mapa de instâncias a serem criadas"
}

/*
variable "instance_type" {
  type        = string
  description = "Tipo da instância EC2 a ser criada"
  default     = "t3.micro"
}

variable "tag_name" {
  type        = string
  description = "Nome da tag"
}
*/

variable "extras_volumes" {
    type        = map(object({
    device_name = string
    volume_size = string
  }))
  description = "Volumes EBS adicionais a serem anexados à instância"
}