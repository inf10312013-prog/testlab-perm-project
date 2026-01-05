#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/testlab"
GROUP="testlab"

echo "==[1] Check directories & setgid =="
ls -ld "$BASE" "$BASE/logs" "$BASE/reports"

echo
echo "==[2] Check ACL defaults (should include default:group::rwX) =="
getfacl -p "$BASE/logs" | sed -n '1,25p'
getfacl -p "$BASE/reports" | sed -n '1,25p'

echo
echo "==[3] Check users are in group testlab =="
id runner || true
id analyst || true

echo
echo "==[4] Shared write test (runner creates, analyst appends) =="
su - runner -c 'echo "k,v" > /srv/testlab/reports/verify.csv'
su - analyst -c 'echo "1,OK" >> /srv/testlab/reports/verify.csv'
cat /srv/testlab/reports/verify.csv

echo
echo "==[5] Permissions of generated file =="
ls -l /srv/testlab/reports/verify.csv
getfacl -p /srv/testlab/reports/verify.csv | sed -n '1,20p'

echo
echo "[OK] verify passed."
