output "instance_ip" {
  description = "Endereço IP privado de uma instância EC2"
  value       = {for id, instances in aws_instance.this : id => instances.private_ip}
}