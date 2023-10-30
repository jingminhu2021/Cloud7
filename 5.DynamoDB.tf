resource "aws_dynamodb_table" "basic-dynamodb-table" {
    name           = "iotdata"
    billing_mode   = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 20
    hash_key       = "timestamp"
    range_key      = "thingId"

    attribute {
        name = "timestamp"
        type = "N"
    }

    attribute {
        name = "thingId"
        type = "S"
    }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = module.vpc.private_route_table_ids
}
