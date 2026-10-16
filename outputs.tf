output "instance_ip" {
  description = "Endereço IP privado de uma instância EC2"
  value       = aws_instance.example-1.private_ip
}