#!/bin/bash

fail=""
match="BOOTPROTO=dhcp"

for file in /etc/sysconfig/networking/devices/* ; do
  if [[ -f $file ]] ; then
    output="$(grep -i $match $file &>/dev/null)"
    if [[ $? == 0 ]]; then
      fail="${fail}
${file}"
    fi
  fi
done

if [[ -z "$fail" ]] ; then
  echo "network.config.dhcp: [OK]"
else
  echo "network.config.dhcp: [FAIL]"
  echo -n "devices configured to use ${match}:"
  echo "$fail"
fi
