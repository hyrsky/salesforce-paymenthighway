#!/usr/bin/env bash

ENCRYPTED_KEY="encrypted.key"
DURATION_DAYS="365"

# Generate private rsa key
if [ ! -f "$ENCRYPTED_KEY" ]; then
    openssl genrsa -aes256 -out "$ENCRYPTED_KEY"
fi

# Create self signed certificate.
openssl req -x509 -key "$ENCRYPTED_KEY" -out server.crt -days "$DURATION_DAYS"
