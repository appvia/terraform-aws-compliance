output "aws_config_recorder_id" {
  description = "The ID of Config recorder"
  value       = aws_config_configuration_recorder.mgmt_config_recorder.id
}

output "aws_config_delivery_channel_id" {
  description = "The ID of Config delivery channel"
  value       = aws_config_delivery_channel.mgmt_config_delivery_channel.id
}
