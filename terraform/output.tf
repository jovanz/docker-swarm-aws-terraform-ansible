##################################################################################
# OUTPUT
##################################################################################

output "master_public_ip" {
    description = "Public IP address of the master"
    value = ["${aws_instance.master.public_ip}"]
}
output "worker1_public_ip" {
    description = "Public IP address of the worker1"
    value = ["${aws_instance.worker1.public_ip}"]
}
output "worker2_public_ip" {
    description = "Public IP address of the worker2"
    value = ["${aws_instance.worker2.public_ip}"]
}
