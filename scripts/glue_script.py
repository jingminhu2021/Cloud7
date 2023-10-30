import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Amazon DynamoDB
AmazonDynamoDB_node1698577330021 = glueContext.create_dynamic_frame.from_options(
    connection_type="dynamodb",
    connection_options={
        "dynamodb.export": "ddb",
        "dynamodb.s3.bucket": "cloud7-dynamodb-bucket",
        "dynamodb.s3.prefix": "temporary/ddbexport/",
        "dynamodb.tableArn": "arn:aws:dynamodb:ap-southeast-1:708779265549:table/iotdata",
        "dynamodb.unnestDDBJson": True,
    },
    transformation_ctx="AmazonDynamoDB_node1698577330021",
)

# Script generated for node Amazon S3
AmazonS3_node1698577333772 = glueContext.write_dynamic_frame.from_options(
    frame=AmazonDynamoDB_node1698577330021,
    connection_type="s3",
    format="csv",
    connection_options={
        "path": "s3://cloud7-dynamodb-bucket/dynamodb",
        "partitionKeys": [],
    },
    transformation_ctx="AmazonS3_node1698577333772",
)

job.commit()
