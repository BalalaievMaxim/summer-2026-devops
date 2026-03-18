#!/bin/bash

# перевірка на root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

N=3
APP_PORT=8000
DB_NAME="mywebappdb"
DB_USER="postgres"
DB_PASSWORD="postgres"
APP_LINUX_USER="mywebapp"
CONFIG_DIR="/etc/mywebapp"
REPO_ROOT=$(dirname $(dirname $(readlink -f $0)))
PUBLISH_DIR="/opt/mywebapp"

echo "1. Installing dependencies"
apt-get update
apt-get install -y wget curl nginx postgresql postgresql-contrib openssh-server
apt-get install -y dotnet-sdk-10.0

echo "2. Creating users"
for user in student teacher; do
    useradd -m -s /bin/bash $user
    echo "$user:12345678" | chpasswd
    usermod -aG sudo $user
    chage -d 0 $user
done

useradd -r -s /usr/sbin/nologin $APP_LINUX_USER

# operator з обмеженим sudo
if getent group operator > /dev/null; then
    useradd -m -s /bin/bash -g operator operator
else
    useradd -m -s /bin/bash operator
fi

echo "operator:12345678" | chpasswd
chage -d 0 operator
cat <<EOF > /etc/sudoers.d/operator
operator ALL=(ALL) NOPASSWD: /usr/bin/systemctl start mywebapp.service, \
                             /usr/bin/systemctl stop mywebapp.service, \
                             /usr/bin/systemctl restart mywebapp.service, \
                             /usr/bin/systemctl status mywebapp.service, \
                             /usr/bin/systemctl reload nginx
EOF

echo "3. Setting up PostgreSQL database"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

echo "4. Publishing the application"
mkdir -p $PUBLISH_DIR
dotnet publish "$REPO_ROOT/src/mywebapp/mywebapp.csproj" -c Release -o $PUBLISH_DIR
chown -R $APP_LINUX_USER:$APP_LINUX_USER $PUBLISH_DIR

mkdir -p $CONFIG_DIR
cat <<EOF > $CONFIG_DIR/config.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=127.0.0.1;Database=$DB_NAME;Username=$DB_USER;Password=$DB_PASSWORD"
  }
}
EOF
chown -R $APP_LINUX_USER:$APP_LINUX_USER $CONFIG_DIR

echo "5. Setting up Systemd (Socket Activation)"
# сокет-файл
cat <<EOF > /etc/systemd/system/mywebapp.socket
[Unit]
Description=mywebapp Socket

[Socket]
ListenStream=$APP_PORT

[Install]
WantedBy=sockets.target
EOF

# сервіс-файл
cat <<EOF > /etc/systemd/system/mywebapp.service
[Unit]
Description=Notes Service
Requires=mywebapp.socket
After=network.target postgresql.service

[Service]
WorkingDirectory=$PUBLISH_DIR
ExecStart=/usr/bin/dotnet $PUBLISH_DIR/mywebapp.dll
Restart=always
User=$APP_LINUX_USER
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
EOF

echo "6. Running services"
systemctl daemon-reload
systemctl enable --now mywebapp.socket
systemctl start mywebapp.service

echo "7. Setting up Nginx as a reverse proxy"
cat <<EOF > /etc/nginx/sites-available/mywebapp
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/mywebapp_access.log;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /health/ {
        deny all;
    }
}
EOF
ln -sf /etc/nginx/sites-available/mywebapp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

echo "8. Creating a gradebook"
echo "$N" > /home/student/gradebook
chown student:student /home/student/gradebook

echo "9. Blocking default user"
DEFAULT_USER=$(id -nu 1000)
if [ ! -z "$DEFAULT_USER" ] && [ "$DEFAULT_USER" != "student" ]; then
    usermod -L $DEFAULT_USER
    echo "User $DEFAULT_USER has been locked"
fi

echo "Deployment complete. You may log in as 'student' or 'teacher' with password '12345678'."