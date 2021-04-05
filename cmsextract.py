#!env python3

# Small tool to extract data from a CMS/PKCS#7 when the signature
# fails to validate. We need this for one specific Masterlist
# which is rejected by BouncyCastle, OpenSSL and the certtool
# utilities.
#

import sys

from OpenSSL import crypto
from OpenSSL._util import ( ffi as _ffi, lib as _utls)

bio_out =crypto._new_mem_buf()

p7 = crypto.load_pkcs7_data(crypto.FILETYPE_ASN1, sys.stdin.buffer.read())

if 1 !=  _utls.PKCS7_verify(p7._pkcs7, _ffi.NULL, _ffi.NULL, _ffi.NULL, bio_out, _utls.PKCS7_NOVERIFY | _utls.PKCS7_NOSIGS):
    err = _ffi.string(_utls.ERR_reason_error_string(_utls.ERR_get_error())) 
    print("Fail to decode: " + err.decode('ASCII'))
    sys.exit(1)

databytes = crypto._bio_to_string(bio_out)
print("Result:")
sys.stdout.buffer.write(databytes)

sys.exit(0)

