output "PublicIP" {
  value = ["${aws_subnet.public.*.id}"]
}

output "PrivateIP" {
  value = ["${aws_subnet.private.*.id}"]
}
