import trustme

ca = trustme.CA()

server_cert = ca.issue_cert(u"localhost")
client_cert = ca.issue_cert(u"client-a")

ca.cert_pem.write_to_path("ca.crt")
server_cert.private_key_pem.write_to_path("server.key")
server_cert.cert_chain_pems[0].write_to_path("server.crt")
client_cert.private_key_pem.write_to_path("client.key")
client_cert.cert_chain_pems[0].write_to_path("client.crt")