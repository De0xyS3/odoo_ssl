#!/bin/bash
echo "Deseas instalar certificado SSL let's encrypt  ? [y,n]"
read input

# did we get an input value?
if [ "$input" == "" ]; then

   echo "Deseas instalar > SI o NO"

# was it a y or a yes?
elif [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then

sudo apt install python3-certbot-nginx
sudo certbot --nginx certonly
set -x
./nginx.sh

# treat anything else as a negative response
else
   echo "Anulado"

fi
