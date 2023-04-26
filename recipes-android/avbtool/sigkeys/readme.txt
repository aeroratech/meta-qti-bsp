--------------------------------------------------------------------------------------------------------------
//Generate rootCA key
$ openssl genrsa -out qpsa_rootca.key 2048

//Generate certificate for rootCA
$ openssl req -new -key qpsa_rootca.key -x509 -out qpsa_rootca.crt \
-subj "/C=US/ST=California/L=San Diego/OU=General Use Test Key (for testing only)/OU=CDMA Technologies/O=None/CN=Generated Root CA 1" \
-days 7300 -set_serial 1 -config opensslroot.cfg -sha256

//Convert crt format to der
$ openssl x509 -inform PEM -in qpsa_rootca.crt -outform DER -out qpsa_rootca.der

--------------------------------------------------------------------------------------------------------------
//Generate attestCA key
$ openssl genrsa -out qpsa_attestca.key 2048


//Generate csr for attestCA
$ openssl req -new -key qpsa_attestca.key -out qpsa_attestca.csr \
-subj "/C=US/ST=CA/L=San Diego/OU=CDMA Technologies/O=None/CN=Generated Attestation CA" \
-days 7300 -config opensslroot.cfg

//Generate certificate for attestCA and signed by rootCA
$ openssl x509 -req -in qpsa_attestca.csr -CA qpsa_rootca.crt -CAkey qpsa_rootca.key -out qpsa_attestca.crt -set_serial 5 -days 7300 -extfile v3.ext -sha256

//Convert crt format to der
$ openssl x509 -inform PEM -in qpsa_attestca.crt -outform DER -out qpsa_attestca.der

--------------------------------------------------------------------------------------------------------------
//Generate attest key
$ openssl genrsa -out qpsa_attest.key 2048

//Generate csr for attest
$ openssl req -new -key qpsa_attest.key -out qpsa_attest.csr \
  -subj  "/C=US/CN=QPSA User/L=San Diego/O=ASIC/ST=California/OU=Test key only" \
  -days 7300 -config opensslroot.cfg

//Generate certificate for attest and signed by attestCA
$ openssl x509 -req -in qpsa_attest.csr -CA qpsa_attestca.crt -CAkey qpsa_attestca.key -outform DER -out qpsa_attest.der -days 7300 -set_serial 38758 -extfile v3_attest.ext -sha256


//Get public key from crt
$ openssl x509 -in qpsa_rootca.crt -pubkey -noout > qpsa_rootca_pubkey.pem
