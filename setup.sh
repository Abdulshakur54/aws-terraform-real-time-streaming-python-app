#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-venv
mkdir app
cat <<EOT > /home/ubuntu/app/main.py
${file("${path.module}/../app/main.py")}
EOT

cat <<EOT > /home/ubuntu/app/WeatherAPI.py
${file("${path.module}/../app/WeatherAPI.py")}
EOT

cat <<EOT > /home/ubuntu/app/requirments.txt
${file("${path.module}/../app/requirements.txt")}
EOT

cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r ~/app/requirements.txt
python3 ~/app/main.py weather-bucket-497308994d301c6a
EOF