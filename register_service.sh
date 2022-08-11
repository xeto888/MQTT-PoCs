#!/bin/bash

#The service uses an incoming cert / pubkey for encrypting the client certs. After encryption, the service sends the certs back to the issuer. 

sleep 5
mosquitto_sub -h 127.0.0.1 -p 666 -t <registertopic> -u <user> -P <MYPW> | while read -r line

# For key creation the openssl is recommended: openssl req -x509 -nodes -newkey rsa:2048 -keyout private-key.pem -out public-key.pem


do
  echo $line > cmds
  base64 -d cmds > decoded_payload
  if grep -q "BEGIN CERTIFICATE" decoded_payload; then
    cat decoded_payload > received_pubkey
    openssl smime -encrypt -binary -aes-256-cbc -in /etc/mosquitto/client-certificates -out encrypted_certs -outform DER received_pubkey
    b64_cert=$(base64 -w 0 encrypted_zip)
    mosquitto_pub -h 127.0.0.1 -p 666 -t <informationtopic> -u <user> -P <MYPW> -m "Registration Completed"
    mosquitto_pub -h 127.0.0.1 -p 666 -t <informationtopic> -u <user> -P <MYPW> -m $b64_cert
    rm decoded_payload
    rm received_pubkey
    rm encrypted_certs

  else 
    mosquitto_pub -h 127.0.0.1 -p 666 -t <informationtopic> -u xeto888 -P <MYPW> -m "Invalid Public Key"
  fi
  echo "" > cmds
done

#CertPW: n8716N!!zzxV 
#Note to myself: Rotations got my heart blazing. Dressed in all black like I'm Jason Statham. Psalm 13 got me feeling David

