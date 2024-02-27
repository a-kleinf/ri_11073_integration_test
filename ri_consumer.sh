#!/bin/bash

args=("$@")

echo Flag indicating to use TLS is "${args[0]}"

ip addr
echo ref_ip is "${ref_ip}"

export ref_fac="theFacility"
export ref_bed="comfyBed"
export ref_poc="noPoint"
if [ "${args[0]}" == "true" ]; then
export ref_ca=$(pwd)/certs
export ref_ssl_passwd=dummypass
fi

echo "Starting sdc11073 provider"

python3 sdc11073_git/examples/ReferenceTest/reference_provider.py &


if [ "${args[0]}" == "true" ]; then
echo "Starting SDCri consumer with TLS"
cd ri && mvn -Dsdcri-version=5.1.1 -Pconsumer-tls -Pallow-snapshots exec:java; ((test_exit_code = $?))
else
echo "Starting SDCri consumer without TLS"
cd ri && mvn -Dsdcri-version=5.1.1 -Pconsumer -Pallow-snapshots exec:java; ((test_exit_code = $?))
fi

echo "Terminating sdc11073 provider"
jobs && kill %1
pkill -f sdc11073

exit "$test_exit_code"