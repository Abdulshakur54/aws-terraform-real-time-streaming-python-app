#!/bin/bash
# the AMI used already has python installed, install python3-pip and python3-venv
sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-venv

# create a directory to store application files
mkdir app

#shell copy project files from your local PC to the remote server
scp -i your-private-key.pem ./app/main.py <ubuntu>@<ec2-ip-address>:~/app
scp -i your-private-key.pem ./app/WeatherAPI.py <ubuntu>@<ec2-ip-address>:~/app
scp -i your-private-key.pem ./app/requirements.txt <ubuntu>@<ec2-ip-address>:~/app

# SSH to the remote server
ssh -i your-private-key.pem <ubuntu>@<ec2-ip-address>

#create a virtual environment and run the python app providing the bucket name from terraform output as parameter
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r ~/app/requirements.txt
python3 ~/app/main.py weather-bucket-497308994d301c6a
