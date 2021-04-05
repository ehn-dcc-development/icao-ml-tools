#-!/bin/sh
set -e

PYTHON=${PYTHON:-python}
DIR=${DIR:-real}
OUTDIR=${OUTDIR:-fake}
mkdir -p ${OUTDIR}

openssl rand 2048 > .rnd

rename_and_to_pem() {
	C=$1
	/bin/echo -n "Processing $C: "
	openssl x509 -in "${DIR}/$C/$2" -inform DER -out ${OUTDIR}/$C-csca-org.pem
	openssl x509 -in "${DIR}/$C/$3" -inform DER -out ${OUTDIR}/$C-link-org.pem
	test $4 && openssl x509 -in "${DIR}/$C/$4" -inform DER -out ${OUTDIR}/$C-dsc-org.pem

	# Verify and extract the CMS.
	if ! test $NO_CMS_SIGN; then
		openssl cms -inform DER -verify \
			-CAfile ${OUTDIR}/$C-csca-org.pem -certfile ${OUTDIR}/$C-link-org.pem \
			--purpose any \
			-in "${DIR}/$C/$5" > ${OUTDIR}/$C-masterlist.der
	else
		echo Warning - skipping verification of signature.
		cat "${DIR}/$C/$5" | $PYTHON cmsextract.py > ${OUTDIR}/$C-masterlist.der
	fi

	# create a fake CSCA - so we can resign the DSCs certs. And a link cert,
 	# signed by this fake CSCA to be able to sign masterlists with DSCs.
	#
	resign -v -K ${OUTDIR}/$C-csca-org.pem > ${OUTDIR}/$C-csca.pem
	resign -v -K ${OUTDIR}/$C-link-org.pem ${OUTDIR}/$C-csca.pem > ${OUTDIR}/$C-link.pem

	# No longer need the originals. Delete these to avoid confusion.
	#
	# rm -f ${OUTDIR}/$C-csca-org.pem ${OUTDIR}/$C-link-org.pem ${OUTDIR}/$C-dsc-org.pem

	cat  ${OUTDIR}/$C-masterlist.der | $PYTHON icao-ml-unpack.py
	for i in cert*der
	do
		# Resign the DSC and have that signed by the CSCA with a fake key,
		#
		openssl x509 -in $i -inform DER -text -out tmp.pem
		resign -K tmp.pem ${OUTDIR}/$C-csca.pem > ${OUTDIR}/$C-`basename $i .der`.pem
		mv $i  ${OUTDIR}/$C-$i
		rm tmp.pem 
	done
	echo Done.
}

# GERMANY (DE)
# Source: https://www.bsi.bund.de/EN/Topics/ElectrIDDocuments/securPKI/securCSCA/Root_Certificate/cscaGermany_node.html

rename_and_to_pem DE \
	csca-germany_05-2019_self_signed.cer \
	csca-germany_05-2019_link.cer \
	20201022_\[CA\]_ME_046f.cer \
	20210315_DEMasterList.ml
	

# NETHERLANDS (NL)
# Source: https://www.npkd.nl

rename_and_to_pem NL \
	"(180621000000Z-310630000000Z) CN=CSCA NL,OU=Kingdom of the Netherlands,O=Kingdom of the Netherlands,C=NL.cer" \
	"Link certificate for (180424085014Z-300302000000Z) CN=CSCA NL,OU=Kingdom of the Netherlands,O=Kingdom of the Netherlands,C=NL.cer" \
	"" \
	"NL_MASTERLIST_20191217.mls" \

# ICAO 
# Source: https://www.icao.int/Security/FAL/PKD/Pages/ICAO-Master-List.aspx

# The CSCA and link certificate does not seem to be available on line. So extract it.
#
dd if=${DIR}/ICAO/ICAO_ML_Jan2021.ml bs=1 skip=423296  count=1632 | openssl x509 -inform DER  -out  ${DIR}/ICAO/ICAO-link.der -outform DER
dd if=${DIR}/ICAO/ICAO_ML_Jan2021.ml bs=1 skip=424736| openssl x509 -inform DER  -out  ${DIR}/ICAO/ICAO-csca.der -outform DER

./ldifdecode-icao fake < real/ICAO/icaopkd-002-ml-000171.ldif

NO_CMS_SIGN=yup rename_and_to_pem ICAO \
	ICAO-csca.der \
	ICAO-link.der \
	"" \
	ICAO_ML_Jan2021.ml 

