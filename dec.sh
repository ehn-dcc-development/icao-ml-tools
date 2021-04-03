cd real/DE

openssl x509 -in \tcsca-germany_05-2019_self_signed.cer -inform DER -out csca.pem
openssl x509 -in  csca-germany_05-2019_link.cer -inform DER -out link.pem
openssl x509 -in 20201022_\[CA\]_ME_046f.cer -inform DER -out dsc.pem

openssl cms -inform DER -verify -in 20210315_DEMasterList.ml \
	-CAfile csca.pem -certfile link.pem \
	--purpose any |\
	python ../../icao-ml-unpack.py

for i in cert*der
do
	openssl x509 -in $i -out `basename $i .der`.pem -inform DER -text
done
