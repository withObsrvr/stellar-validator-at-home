#!/bin/bash

domains=(history.core-live-a.example.com)
email="your-email@example.com" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

data_path="./data/certbot"
rsa_key_size=4096

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$data_path/conf/live/$domains/privkey.pem' \
    -out '$data_path/conf/live/$domains/fullchain.pem' \
    -subj '/CN=localhost'" certbot

echo "### Creating dummy certificate for $domains ..."

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot

echo "### Requesting Let's Encrypt certificate for $domains ..."
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $domain_args \
    --email $email \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload