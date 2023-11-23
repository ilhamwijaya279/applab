#!/bin/bash

# Update package list
sudo apt update

# Install Nginx
sudo apt install -y nginx

# Backup the default Nginx configuration
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Create a new Nginx configuration
sudo tee /etc/nginx/nginx.conf > /dev/null <<'EOF'
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    upstream backend {
        server 192.168.56.11:3000;
        server 192.168.56.15:3000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Restart Nginx to apply the changes
sudo systemctl restart nginx