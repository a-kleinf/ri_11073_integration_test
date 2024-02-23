#!/bin/bash

echo Flag indicating to use TLS is "${args[0]}"

ip addr
echo ref_ip is "${ref_ip}"

if [ "${args[0]}" == "true" ]; then
    export ref_ca=$(pwd)/certs
    export ref_ssl_passwd=dummypass
fi
export ref_search_epr=""

if [ "${args[0]}" == "true" ]; then
echo "Starting SDCri provider with TLS"
(cd ri && sleep 999999999 | mvn -Pprovider-tls -Pallow-snapshots exec:java) &
else
echo "Starting SDCri provider without TLS"
(cd ri && sleep 999999999 | mvn -Pprovider -Pallow-snapshots exec:java) &
fi
sleep 20

cd sdc11073_git 
echo "Starting sdc11073 consumer reference_consumer"
python3 -m examples.ReferenceTest.reference_consumer; ((test_exit_code = $?))
echo "Starting sdc11073 consumer test_client_connects"
python3 -m unittest examples.ReferenceTest.test_reference.Test_Reference.test_client_connects; ((test_exit_code = test_exit_code || $?))

echo "Terminating SDCri provider"
jobs && kill %1

exit "$test_exit_code"