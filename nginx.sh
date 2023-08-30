#!/bin/bash

cd /etc/nginx/sites-available/

echo "Ingresa el dominio completo (ejemplo: midominio.com)"
read full_domain

# Obtener el nombre del dominio y su extensión.
domain_name=$(echo $full_domain | cut -d. -f1)
domain_extension=$(echo $full_domain | cut -d. -f2-)

echo "Ingresa el puerto utilizado del contenedor"
read puerto

cat << EOF > $full_domain.conf

# vim $full_domain.conf 

upstream odooserver-$domain_name {
     server 127.0.0.1:$puerto;
}

server {
    listen [::]:80;
    listen 80;

    server_name $full_domain www.$full_domain;

    return 301 https://$full_domain/\$request_uri;
}

server {
    listen [::]:443 ssl;
    listen 443 ssl;

    server_name www.$full_domain;

    ssl_certificate /etc/letsencrypt/live/$full_domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$full_domain/privkey.pem;

    return 301 https://$full_domain\$request_uri;
}

server {
    listen [::]:443 ssl http2;
    listen 443 ssl http2;

    server_name $full_domain;

    ssl_certificate /etc/letsencrypt/live/$full_domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$full_domain/privkey.pem;

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
        proxy_pass http://odooserver-$domain_name;
    }

    location ~* /web/static/ {
        proxy_cache_valid 200 90m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odooserver-$domain_name;
    }

    gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
    gzip on;
}

EOF

ln -s /etc/nginx/sites-available/$full_domain.conf /etc/nginx/sites-enabled/$full_domain.conf
nginx -t
if [ $? -ne 0 ]; then
    echo "Configuración de nginx errónea"
else
    service nginx restart

    echo "INSTALACION FINALIZADA. ODOO DOCKER CONTAINER SE ESTA EJECUTANDO"
    echo "[`date +%m/%d/%Y-%H:%M`] INSTALACION FINALIZADA.. ODOO DOCKER CONTAINER ESTA INICIADO Y EJECUTANDO"
    echo "Accede a odoo web desde el siguiente URL https://$full_domain"

fi
