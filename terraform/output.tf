##################################################################################
# OUTPUT
##################################################################################

output "manager_public_ip" {
  description = "Public IP address of the manager"
  value       = ["${aws_instance.manager.public_ip}"]
}
output "worker1_public_ip" {
  description = "Public IP address of the worker1"
  value       = ["${aws_instance.worker1.public_ip}"]
}
output "worker2_public_ip" {
  description = "Public IP address of the worker2"
  value       = ["${aws_instance.worker2.public_ip}"]
}
