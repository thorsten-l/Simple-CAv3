#!/bin/sh

CAPASS=`cat ca-root.pwd`

if [ -f ca-root.key ]; then 
  echo CA Root key already exists
else
  openssl genrsa -aes256 -passout pass:$CAPASS -out ca-root.key 2048
  openssl req -x509 -passin pass:$CAPASS \
   -subj '/C=SW/ST=Tatooine/L=Mos Eisley/OU=IoT/O=Galactic Republic/CN=ca.tatooine.sw/' \
   -new -nodes -extensions v3_ca \
   -key ca-root.key -days 10950 -out ca-root.crt -sha512
fi
