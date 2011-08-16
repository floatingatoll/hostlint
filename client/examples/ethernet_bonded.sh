#!/bin/bash

# "verify that eth0 and eth1 are bonded"
# this should likely be generalized

if [[ -d /proc/net/bonding ]]  ; then
  for file in /proc/net/bonding/* ; do
    if grep 'eth0' $file &>/dev/null && grep 'eth1' $file &>/dev/null ; then
      echo "network.ethernet.bonded: [OK]"
      exit 0
    fi
  done
fi

# fell thru
echo "network.ethernet.bonded: [FAIL]
output of ifconfig:
$(ifconfig 2>/dev/null)"
