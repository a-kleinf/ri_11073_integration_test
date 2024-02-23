#!/bin/bash

ip addr
echo ref_ip is "${ref_ip}"

export ref_ca=$(pwd)/certs
export ref_ssl_passwd=dummypass

echo "Starting SDCri provider"
(cd ri && sleep 999999999 | mvn -Pprovider-tls -Pallow-snapshots exec:java) &
sleep 30
echo "Starting sdc11073 consumer reference_consumer"
python3 "examples\ReferenceTest\reference_consumer.py"; ((test_exit_code = $?))
echo "Starting sdc11073 consumer test_client_connects"
cd sdc11073_git && python3 -m unittest examples.ReferenceTest.test_reference.Test_Reference.test_client_connects; ((test_exit_code = test_exit_code || $?))

echo "Terminating SDCri provider"
jobs && kill %1

exit "$test_exit_code"