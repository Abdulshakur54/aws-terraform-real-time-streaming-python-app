output "bucket_name" {
  value       = aws_s3_bucket.weather_bucket.bucket
  description = "Name of the S3 bucket"
}

output "ec2_public_ip" {
  value       = aws_instance.ec2_server.public_ip
  description = "Public IP address of the EC2 instance"
}