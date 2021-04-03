from asn1tinydecoder import asn1_node_root, asn1_get_all, asn1_get_value, \
                        asn1_get_value_of_type, asn1_node_next, asn1_node_first_child, \
                        asn1_read_length, asn1_node_is_child_of, \
                        bytestr_to_int, bitstr_to_bytestr

import sys
der = sys.stdin.buffer.read()

i = asn1_node_root(der)

i = asn1_node_first_child(der,i)

hdr  = 	asn1_node_next(der,i)
hdr = asn1_node_first_child(der,hdr)

print("Certs")

k = 0
while asn1_node_is_child_of(hdr,i):
	i = asn1_node_next(der,i)
	with open('cert-{:05d}.der'.format(k),'wb') as f:
		f.write(asn1_get_all(der,i))
	k = k + 1

