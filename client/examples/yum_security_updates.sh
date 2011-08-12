#!/bin/bash
# requirith yum-plug-in-security

output="$(yum --security check-update 2>/dev/null)"

if [[ $? == 100 ]] ; then #security updates exist!
    echo "yum.security.updates.available: [FAIL]"
    echo "$output" | tail -n +3
else
    echo "yum.security.updates.available: [OK]"
fi
