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