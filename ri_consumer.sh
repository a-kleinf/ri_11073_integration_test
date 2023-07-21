#!/bin/bash

args=("$@")

echo arg1 is "${args[0]}"

ip addr
echo ref_ip is "${ref_ip}"

export ref_fac="theFacility"
export ref_bed="comfyBed"
export ref_poc="noPoint"
export ref_ca=$(pwd)/certs
export ref_ssl_passwd=dummypass

echo "Starting sdc11073 provider"

if [ "${args[0]}" == "v1.x.y" ]; then
    python3 sdc11073_git/examples/ReferenceTest/reference_device.py &
else 
    python3 sdc11073_git/examples/ReferenceTest/reference_provider.py &
fi
echo "Starting SDCri consumer"
cd ri && mvn -Pconsumer-tls -Pallow-snapshots exec:java
test_exit_code=$?

echo "Terminating sdc11073 provider"
jobs && kill %1
pkill -f sdc11073

exit "$test_exit_code"