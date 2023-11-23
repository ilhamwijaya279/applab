#!/bin/bash

# RabbitMQ credentials
RABBITMQ_USER="guest"
RABBITMQ_PASS="Admin123"

# RabbitMQ server details
RABBITMQ_HOST="localhost"
RABBITMQ_PORT="15672"  # Default management port

# Exchange and Queue details
EXCHANGE_NAME="notifExchange"
QUEUE_NAME="notifQueue"

sudo yum install epel-release -y

# Update package list
sudo yum update -y

# Install RabbitMQ
sudo yum install rabbitmq-server -y

# Start RabbitMQ server
sudo systemctl start rabbitmq-server

# Enable RabbitMQ to start on boot
sudo systemctl enable rabbitmq-server

# Enable the RabbitMQ management plugin
sudo rabbitmq-plugins enable rabbitmq_management

# Restart RabbitMQ for changes to take effect
sudo systemctl restart rabbitmq-server

# Change the default password
sudo rabbitmqctl change_password $RABBITMQ_USER $RABBITMQ_PASS

sudo yum install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Set up firewall rules
sudo firewall-cmd --zone=public --permanent --add-port=5672/tcp
sudo firewall-cmd --zone=public --permanent --add-port=15672/tcp
sudo firewall-cmd --reload

# Display status of RabbitMQ server
sudo systemctl status rabbitmq-server

# Create Exchange
curl -i -u $RABBITMQ_USER:$RABBITMQ_PASS -H "content-type:application/json" -XPUT http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/exchanges/%2f/$EXCHANGE_NAME -d '{"type":"direct","durable":true}'

# Create Queue
curl -i -u $RABBITMQ_USER:$RABBITMQ_PASS -H "content-type:application/json" -XPUT http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/queues/%2f/$QUEUE_NAME -d '{"durable":true}'

# Bind Queue to Exchange
curl -i -u $RABBITMQ_USER:$RABBITMQ_PASS -H "content-type:application/json" -XPOST http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/bindings/%2f/e/$EXCHANGE_NAME/q/$QUEUE_NAME -d '{}'