#!/bin/bash

args=("$@")
echo sdcri-version is "${args[0]}"
echo flag indicating to use TLS is "${args[1]}"

if [ "${args[1]}" == "true" ]; then
echo "Starting sdc11073 provider with TLS"
python3 sdc11073_git/pat/provider.py -Dadapter=127.0.0.1 -Depr=urn:uuid:12345678-6f55-11ea-9697-123456789abc -Dcertificate-folder=$(pwd)/certs -Dpassword=dummypass &
else
echo "Starting sdc11073 provider without TLS"
python3 sdc11073_git/pat/provider.py -Dadapter=127.0.0.1 -Depr=urn:uuid:12345678-6f55-11ea-9697-123456789abc &
fi

if [ "${args[1]}" == "true" ]; then
echo "Starting SDCri consumer with TLS"
cd ri && mvn -Dsdcri-version=${args[0]} -Pconsumer-tls -Pallow-snapshots exec:java; ((test_exit_code = $?))
else
echo "Starting SDCri consumer without TLS"
cd ri && mvn -Dsdcri-version=${args[0]} -Pconsumer -Pallow-snapshots exec:java; ((test_exit_code = $?))
fi

echo "Terminating sdc11073 provider"
jobs && kill %1
pkill -f sdc11073

exit "$test_exit_code"