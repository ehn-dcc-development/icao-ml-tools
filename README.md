Tools to extract ML's of countries for testing.

Run ```decode-and-regerate.sh ``` to decode the signed MLs, extract the certificates and also create 'fake' certificates that have a known private key.

# Dependencies

This requires the resign ulility from

	https://github.com/ehn-digital-green-development/x509-resign

# Files

*  asn1tinydecoder.py - Modified https://github.com/getreu/asn1-tiny-decoder to deal with an end of loop issue
*  cmsextract.py - Script to exact the payload of a PKCS#7 / CMS binary (needed when the signature does not validate) without any checks.
* gen-trust.list.sh - Parse the MasterLists in real/* and convert these into 'fake ones'
* decode-and-regerate.sh - Show some info about the DSCs
* icao-ml-unpack.py - Script to unpack the ASN.1 packaged master lists.
