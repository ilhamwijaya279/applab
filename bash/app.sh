#!/bin/bash

SERVICE_NAME="applabs"
USERNAME="ubuntu"
APP_PATH="/home/${USERNAME}/applab/app.py"

sudo apt update
sudo apt install python3-pip python3-waitress -y

git clone https://github.com/ilhamwijaya279/applab.git
pip3 install flask pika pymemcache pymysql python-dotenv

# Create the service file
sudo bash -c "cat >/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=DevOpsTools and Labs Flask App
After=network.target

[Service]
User=${USERNAME}
Group=${USERNAME}
WorkingDirectory=$(dirname "${APP_PATH}")
ExecStart=waitress-serve --host=0.0.0.0 --port=3000 ${APP_PATH}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start ${SERVICE_NAME}
sudo systemctl enable ${SERVICE_NAME}

# Check the status of the service
sudo systemctl status ${SERVICE_NAME}
