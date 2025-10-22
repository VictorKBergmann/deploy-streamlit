output "public_ip" {
  description = "IP Público da instância EC2"
  value       = aws_instance.app_server.public_ip
}