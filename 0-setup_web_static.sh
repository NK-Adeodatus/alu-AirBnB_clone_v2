#!/usr/bin/env bash
# sets up the web servers for the deployment of web_static

sudo apt-get -y update
sudo apt-get -y install nginx
sudo mkdir -p /data/web_static/releases/test /data/web_static/shared

# Create proper HTML content matching expected output
sudo tee /data/web_static/releases/test/index.html > /dev/null << EOF
<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>
EOF

sudo ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -hR ubuntu:ubuntu /data/

# Add Nginx configuration if not already present
if ! sudo grep -q "location /hbnb_static" /etc/nginx/sites-available/default; then
    sudo sed -i '/location \/ {/i\
\	location /hbnb_static {\
\		alias /data/web_static/current/;\
\	}\
' /etc/nginx/sites-available/default
fi

sudo service nginx restart
