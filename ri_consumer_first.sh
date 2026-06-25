#!/bin/bash

args=("$@")
echo flag indicating to use TLS is "${args[0]}"

ip addr
epr="urn:uuid:12345678-6f55-11ea-9697-123456789abc"
ip_addr="127.0.0.1"
cert_path="$(pwd)/certs"
cert_passwd="dummypass"

sdc11073_path="$(pwd)/sdc11073_git"

if [ "${args[0]}" == "true" ]; then
  echo "Starting sdpi consumer with TLS"
  disableTls_value="false"
else
  echo "Starting sdpi consumer without TLS"
  disableTls_value="true"
fi

config="$(mktemp --suffix=.toml)"
cat > "$config" << EOF
[consumer]
epr = "$epr"
address = "$ip_addr"
writeCommlog = true
[consumer.tls]
disableTls = $disableTls_value
publicKeyFile = "$cert_path/user_certificate_root_signed.pem"
privateKeyFile = "$cert_path/user_private_key_encrypted.pem"
caCertFile = "$cert_path/root_certificate.pem"
privateKeyPassword = "$cert_passwd"
EOF

# Start the sdpi consumer first, in the background, and remember its PID.
(cd sdpi_git && ./gradlew run -PchooseMain=org.somda.sdpi.test.v2.consumer.MainKt --args="--config ${config}") &
consumer_pid=$!

sleep 30  # Wait for the consumer to initialize before starting the provider.

# Then start the sdc11073 provider.
if [ "${args[0]}" == "true" ]; then
  echo "Starting sdc11073 provider with TLS"
  PYTHONPATH=$sdc11073_path python3 -m pat.provider --epr $epr --ip $ip_addr --certificate-folder $cert_path --ssl-password $cert_passwd &
else
  echo "Starting sdc11073 provider without TLS"
  PYTHONPATH=$sdc11073_path python3 -m pat.provider --epr $epr --ip $ip_addr &
fi

# Wait for the consumer to finish and capture its exit code.
wait "$consumer_pid"; test_exit_code=$?

echo "Terminating sdc11073 provider"
pkill -f pat.provider

exit "$test_exit_code"