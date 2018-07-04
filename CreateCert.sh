#!/bin/sh

CAPASS=`cat ca-root.pwd`

CN="test1.local"

rm -fv $CN.*

openssl genrsa -out "$CN.key" 2048

cat > $CN.reqcfg <<EOT
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
C=SW
ST=Tatooine
L=Mos Eisley
O=Galactic Republic
OU=IoT
CN=$CN
EOT

openssl req -new -key "$CN.key" -out "$CN.csr" -sha512 -passin pass: \
  -config $CN.reqcfg 

cat > $CN.sigcfg <<EOT
[ server ]
keyUsage                = critical,digitalSignature,keyEncipherment
extendedKeyUsage        = serverAuth
basicConstraints        = CA:FALSE
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer:always
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $CN
EOT

openssl x509 -req -in "$CN.csr" \
        -CA ca-root.crt -CAkey ca-root.key -CAcreateserial \
        -passin pass:$CAPASS \
        -out "$CN.crt" -days 3650 -sha512 \
        -extfile $CN.sigcfg -extensions server

cat ca-root.crt >> "$CN.crt"

openssl rsa -in "$CN.key" -outform DER -out "$CN.key.der"
openssl x509 -in "$CN.crt" -outform DER -out "$CN.crt.der"

xxd -i "$CN.key.der" > "$CN.key.h"
xxd -i "$CN.crt.der" > "$CN.crt.h"
