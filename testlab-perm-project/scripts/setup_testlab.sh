#!/usr/bin/env bash
set -euo pipefail

GROUP="testlab"
BASE="/srv/testlab"
USERS=("runner" "analyst")

# 1) group
getent group "$GROUP" >/dev/null 2>&1 || groupadd "$GROUP"

# 2) users
for u in "${USERS[@]}"; do
  id "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u"
  usermod -aG "$GROUP" "$u"
done

# 3) dirs
mkdir -p "$BASE/logs" "$BASE/reports"

# 4) group ownership
chgrp -R "$GROUP" "$BASE"

# 5) setgid directories so new files inherit group=testlab
# 2775 = rwxrwsr-x
chmod 2775 "$BASE" "$BASE/logs" "$BASE/reports"

# 6) ACL: ensure group has rwX and NEW files/dirs inherit it
setfacl -m g::rwX "$BASE" "$BASE/logs" "$BASE/reports"
setfacl -d -m g::rwX "$BASE" "$BASE/logs" "$BASE/reports"

echo "[OK] testlab setup done."
echo "BASE=$BASE, GROUP=$GROUP, USERS=${USERS[*]}"
