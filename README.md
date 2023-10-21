# Infrastructure Deployment with Terraform

## Initial Setup

1. **Create an AWS Profile:** Set up a custom AWS profile on your local machine to deploy the infrastructure. Use the following command:

   ```bash
   aws configure --profile cloud7
   ```

    Provide the following values when prompted:
    ```bash
    AWS Access Key ID [None]: <your access key>
    AWS Secret Access Key [None]: <your secret key>
    Default region name [None]: ap-southeast-1
    Default output format [None]: json
    ```
    > **Note:** The AWS profile name is `cloud7` in this example. You can use any name you want.

## Initial Deployment
1. Clone the Repository: Clone this repository to your local machine.

2. Initialize Terraform: Run the following command to initialize Terraform:

   ```bash
   terraform init
   ```

3. Deploy the Infrastructure: Run the following command to deploy the infrastructure:

   ```bash
    terraform apply
    ```
    > **Note:** You will be prompted to enter the AWS profile name. Enter the name of the profile you created in the earlier step.
