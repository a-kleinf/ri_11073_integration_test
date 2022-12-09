#!/bin/bash

ip addr
echo ref_ip is "${ref_ip}"

export ref_ca=$(pwd)/certs
export ref_ssl_passwd=dummypass

echo "Starting sdc11073 provider"
python3 -m sdc11073.examples.ReferenceTest.reference_device --tls &
echo "Starting SDCri consumer"
cd ri && mvn -Pconsumer-tls exec:java
test_exit_code=$?

echo "Terminating sdc11073 provider"
jobs && kill %1
pkill -f sdc11073

exit "$test_exit_code"