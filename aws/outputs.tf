output "ec2_global_ips" {
  value = ["${aws_instance.prometheus-stack.*.public_ip}"]
}

