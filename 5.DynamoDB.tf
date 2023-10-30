resource "aws_dynamodb_table" "basic-dynamodb-table" {
    name           = "iotdata"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "thingId"
    range_key      = "timestamp"

    attribute {
        name = "thingId"
        type = "S"
    }

    attribute {
        name = "timestamp"
        type = "N"
    }

    lifecycle {
        ignore_changes = [read_capacity, write_capacity]
    }

}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = module.vpc.private_route_table_ids
}


resource "aws_appautoscaling_target" "environment_table_read_target" {
  max_capacity       = 20
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.basic-dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "environment_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.environment_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.environment_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.environment_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.environment_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70.0
  }
}

resource "aws_appautoscaling_target" "environment_table_write_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.basic-dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "environment_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.environment_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.environment_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.environment_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.environment_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70.0
  }
}
