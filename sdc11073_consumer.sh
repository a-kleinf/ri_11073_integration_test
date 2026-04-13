#!/bin/bash

args=("$@")
echo flag indicating to use TLS is "${args[0]}"

ip addr
epr="urn:uuid:87654321-6f55-1314-9697-123456789cba"
ip_addr="127.0.0.1"
cert_path="$(pwd)/certs"
cert_passwd="dummypass"
timeout_ref_provider="120"

if [ "${args[0]}" == "true" ]; then
  echo "Starting sdpi provider with TLS"
  disableTls_value="false"
else
  echo "Starting sdpi provider without TLS"
  disableTls_value="true"
fi

config="$(mktemp --suffix=.toml)"
cat > "$config" << EOF
[provider]
epr = "$epr"
address = "$ip_addr"
writeCommlog = true
[provider.tls]
disableTls = $disableTls_value
publicKeyFile = "$cert_path/user_certificate_root_signed.pem"
privateKeyFile = "$cert_path/user_private_key_encrypted.pem"
caCertFile = "$cert_path/root_certificate.pem"
privateKeyPassword = "$cert_passwd"
EOF

(cd sdpi_git && ./gradlew run -PchooseMain=org.somda.sdpi.test.v2.provider.MainKt --args="--config ${config}") &

cd sdc11073_git
if [ "${args[0]}" == "true" ]; then
  echo "Starting sdc11073 consumer with TLS"
  python3 -m pat.consumer --epr $epr --ip $ip_addr --certificate-folder $cert_path --ssl-password $cert_passwd --timeout-ref-provider $timeout_ref_provider; ((test_exit_code = $?))
else
  echo "Starting sdc11073 consumer without TLS"
  python3 -m pat.consumer --epr $epr --ip $ip_addr --timeout-ref-provider $timeout_ref_provider; ((test_exit_code = $?))
fi

echo "Terminating SDCri provider"
jobs && kill %1

exit "$test_exit_code"