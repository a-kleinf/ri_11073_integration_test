#!/bin/bash

ip addr
echo ref_ip is "${ref_ip}"

export ref_ca=$(pwd)/certs
export ref_ssl_passwd=dummypass

echo "Starting SDCri provider"
(cd ri && sleep 999999999 | mvn -Pprovider -Pallow-snapshots exec:java) &
sleep 30
echo "Starting sdc11073 consumer"
cd sdc11073_git && python3 -m unittest examples.ReferenceTest.test_reference.Test_Reference.test_client_connects
test_exit_code=$?

echo "Terminating SDCri provider"
jobs && kill %1

exit "$test_exit_code"