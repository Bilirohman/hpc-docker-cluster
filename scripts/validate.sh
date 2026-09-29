#!/usr/bin/env bash
NODES=(head compute1 compute2)
SSH="ssh -o BatchMode=yes -o ConnectTimeout=5"
PASS=0; FAIL=0

check() {
  if bash -c "$2" >/dev/null 2>&1; then
    echo "[PASS] $1"; PASS=$((PASS+1))
  else
    echo "[FAIL] $1"; FAIL=$((FAIL+1))
  fi
}

for n in "${NODES[@]}"; do
  echo "=== Node: $n ==="
  check "head -> $n : login SSH key tanpa password" "$SSH $n true"
  check "$n : hostname sesuai"                      "[ \"\$($SSH $n hostname)\" = \"$n\" ]"
  check "$n : editor nano terinstal"                "$SSH $n 'command -v nano'"
  check "$n : editor vim terinstal"                 "$SSH $n 'command -v vim'"
  check "$n : openssh-client terinstal"             "$SSH $n 'command -v ssh'"
  check "$n : openssh-server terinstal"             "$SSH $n 'test -x /usr/sbin/sshd'"
  check "$n : sshd mendengarkan port 22"            "$SSH $n 'nc -z localhost 22'"
done

echo "=== Konektivitas antar-node (full mesh) ==="
for a in "${NODES[@]}"; do
  for b in "${NODES[@]}"; do
    [ "$a" = "$b" ] && continue
    check "$a -> $b : SSH" "$SSH $a '$SSH $b true'"
  done
done

echo
echo "RINGKASAN: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]