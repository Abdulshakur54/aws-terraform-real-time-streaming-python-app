## AWS Terraform Real Time Streaming Python App

> This project uses boto3 python library running in an EC2 instance to read streaming data from OpenWeatherAPI into AWS S3. It is a higly secure and production ready application. 
- It uses remote S3 backend with DynamoDB to store the terraform state file.
  - S3 will make the state files to be encrypted at rest and in transit. 
  - DynamoDB will ensures state locking. 
  - The above implementations allows a team of engineers to work in same project while enforcing only one user or process to modify terraform state files at a time 
- AWS Secret Manager to store all secrets
  - This ensures that secrets are not hard coded or written together with the application codes
  - Avoid using enviromental variables instead it uses API calls to AWS anytime the secret is needed in the application
  - Secrets are encrypted at rest and in transit and are automatically rotated by AWS
- VPC Gateway Enpoints to communicate with s3
  - This ensure that the EC2 instance communicates with S3 using AWS internal network making faster and more secure as it avoids using the public internet
  - VPC Gateway Endpoints is a free service of AWS

  ### Steps followed in carrying out this project
  1. In the AWS Console, Secrets were added to secret manager, An S3 bucket was created to store terraform remote state files
  2. In Visual Studio Code, A new project folder was created. A python virtual environment was created with all project dependencies installed. project dependencies can be found in [requirements.txt](./app/requirements.txt)
  3. Terraform was used to provision S3 bucket to store weather data
  4. The rest of the python scripts found in the [app folder](./app/) was written and then tested
  5. Terraform was used to deploy the remaining infrastructe. terraform module used is found in [iac folder](./iac/)
  6. SSH access into the  EC2 instance and run the scripts [setup.sh](./setup.sh)

  The project collects realtime weather data from New York, London and Lagos at 5 minutes interval.
  








  _Thanks for viewing_
