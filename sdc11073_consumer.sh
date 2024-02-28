#!/bin/bash
args=("$@")
echo sdcri-version is "${args[0]}"
echo flag indicating to use TLS is "${args[1]}"

ip addr
echo ref_ip is "${ref_ip}"

if [ "${args[1]}" == "true" ]; then
    export ref_ca=$(pwd)/certs
    export ref_ssl_passwd=dummypass
fi
export ref_search_epr=""
# ref_discovery_runs defines the maximum executions of searching services via sdc11073 wsdiscovery
export ref_discovery_runs="20"
# EXTERNAL_DEVICE_RUNNING="true" indicates unittest in sdc11073 that an external SDC Provider is started
export EXTERNAL_DEVICE_RUNNING="true"

if [ "${args[1]}" == "true" ]; then
echo "Starting SDCri provider with TLS"
(cd ri && sleep 999999999 | mvn -Dsdcri-version=${args[0]} -Pprovider-tls -Pallow-snapshots exec:java) &
else
echo "Starting SDCri provider without TLS"
(cd ri && sleep 999999999 | mvn -Dsdcri-version=${args[0]} -Pprovider -Pallow-snapshots exec:java) &
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