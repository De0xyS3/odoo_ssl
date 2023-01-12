#!/bin/bash

cd /etc/nginx/sites-available/

echo "Ingresa el nombre de dominio"
read input
##### elif [[ "$input" == "" ]] || [[ "$input" == "" ]]; then
echo "Ingresa el puerto utilizado del contendor"
read puerto

cat << EOF > $input.conf

# vim $input.conf 

upstream odooserver-$input {
     server 127.0.0.1:$puerto;
 }

 server {
     listen [::]:80;
     listen 80;

     server_name $input.com www.$input.com;

     return 301 https://$input.com/$request_uri;
 }

 server {
     listen [::]:443 ssl;
     listen 443 ssl;

     server_name www.$input.com;

     ssl_certificate /etc/letsencrypt/live/$input.com/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/$input.com/privkey.pem;

     return 301 https://$input.com\$request_uri;
 }

 server {
     listen [::]:443 ssl http2;
     listen 443 ssl http2;

     server_name $input.com;

     ssl_certificate /etc/letsencrypt/live/$input.com/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/$input.com/privkey.pem;

     access_log /var/log/nginx/odoo_access.log;
     error_log /var/log/nginx/odoo_error.log;

     proxy_read_timeout 720s;
     proxy_connect_timeout 720s;
     proxy_send_timeout 720s;
     proxy_set_header X-Forwarded-Host \$host;
     proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto \$scheme;
     proxy_set_header X-Real-IP \$remote_addr;

     location / {
        proxy_redirect off;
        proxy_pass http://odooserver-$input;
     }

     location ~* /web/static/ {
         proxy_cache_valid 200 90m;
         proxy_buffering on;
         expires 864000;
         proxy_pass http://odooserver-$input;
     }

     gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
     gzip on;
 }

EOF

ln -s /etc/nginx/sites-available/$input.conf /etc/nginx/sites-enabled/$input.conf
nginx -t
if [ $? -ne 0 ]; then
        echo "Configuraciòn de nginx errònea"
else
        service nginx restart

echo "INSTALACION FINALIZADA. ODOO DOCKER CONTAINER SE ESTA EJECUTANDO" 
echo "[`date +%m/%d/%Y-%H:%M`] INSTALACION FINALIZADA.. ODOO DOCKER CONTAINER ESTA INICIADO Y EJECUTANDO" 
echo "Accede a odoo web desde el siguiente URL https://$input.com" 


fi
