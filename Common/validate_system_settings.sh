#!/bin/bash
# ------------------------------------------------------------------------------
# Checks for errors in system settings other than those caused by a missing
# bridge device (libvirt module).
#
# See issue #75
# ------------------------------------------------------------------------------

rc=0

while IFS= read -r line
do
  case "${line}" in
    "error: \"net.bridge.bridge-nf-call-ip6tables\" is an unknown key" | \
    "error: \"net.bridge.bridge-nf-call-iptables\" is an unknown key"  | \
    "error: \"net.bridge.bridge-nf-call-arptables\" is an unknown key")
      ;;
    "error: "*)
      printf "%s\n" "${line}" >&2
      rc=1
      ;;
    *)
      ;;
  esac
done <<<$(sysctl -p 2>&1)

exit ${rc}
