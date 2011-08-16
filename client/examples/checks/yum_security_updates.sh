#!/bin/bash
# requirith yum-plugin-security

output="$(yum --security check-update 2>/dev/null)"

if [[ $? == 100 ]] ; then #security updates exist!
    echo "yum.security.updates.available: [FAIL]"
    echo "you could try \"yum --security update\""
    echo "$output" | tail -n +3
else
    echo "yum.security.updates.available: [OK]"
fi
