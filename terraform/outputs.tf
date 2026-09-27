output "ec2_public_ip" {
  description = "Public IP address of the E-Commerce EC2 server"
  value       = aws_instance.ecommerce_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the E-Commerce EC2 server"
  value       = aws_instance.ecommerce_server.public_dns
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}"
}

output "user_service_health" {
  description = "User Service health check URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3001/health"
}

output "product_service_health" {
  description = "Product Service health check URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3002/health"
}

output "cart_service_health" {
  description = "Cart Service health check URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3003/health"
}

output "order_service_health" {
  description = "Order Service health check URL"
  value       = "http://${aws_instance.ecommerce_server.public_ip}:3004/health"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ecommerce-key.pem ubuntu@${aws_instance.ecommerce_server.public_ip}"
}
