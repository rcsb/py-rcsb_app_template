#!/bin/bash
# File: LAUNCH80.sh
# Date: 28-Jun-2020 jdw
#
#  Example deployment using a uvicorn server
#
#  Run as root to bind to port 80:
#
#  sudo OE_LICENSE=<path> -s ./scripts/LAUNCH80.sh >& LOGTODAY
#
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$(dirname "$HERE")"
export OE_LICENSE=${OE_LICENSE:=~/oe_license.txt}
echo "HERE=${HERE}"
echo "TOPDIR=${TOPDIR}"
#
THISIP=0.0.0.0
THISPORT=80
#
cd ${TOPDIR}
python3.9 -m uvicorn --workers 2 --host ${THISIP} --port ${THISPORT} --reload --forwarded-allow-ips ${THISIP} rcsb.app.template.main:app