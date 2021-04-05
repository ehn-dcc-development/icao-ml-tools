#!/bin/sh
set -e

# Run through the entire list of fake DSCs and make a 'new', simplified masterlist of
# the KID, hcert style and the public key
#
openssl fake/*
for i in fake/*-cert-*.pem
do
        KID=$(openssl x509 -in $i -noout -fingerprint -sha256 | sed -e 's/.*=//' -e 's/://g' | cut -c 1-16)
        TPE=$(openssl pkey -in $i -pubout | openssl pkey -pubin -text -noout  | grep bit)
	DN=$(openssl x509 -in $i -noout -subject)
	/bin/echo "$i	$KID	$TPE	$DN"
done
