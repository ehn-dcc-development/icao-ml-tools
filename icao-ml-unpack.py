from asn1tinydecoder import asn1_node_root, asn1_get_all, asn1_get_value, \
                        asn1_get_value_of_type, asn1_node_next, asn1_node_first_child, \
                        asn1_read_length, asn1_node_is_child_of
# bytestr_to_int, bitstr_to_bytestr

import sys
der = sys.stdin.buffer.read()

root = asn1_node_root(der)
hdr = asn1_node_first_child(der,root)

list = asn1_node_next(der,hdr)
item = asn1_node_first_child(der,list)

k = 0
while asn1_node_is_child_of(list, item):
	with open('cert-{:05d}.der'.format(k),'wb') as f:
		f.write(asn1_get_all(der,item))
	k = k + 1
	item = asn1_node_next(der,item)

print("Decoded {:d} certs.".format(k));
