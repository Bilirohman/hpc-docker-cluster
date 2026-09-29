#!/usr/bin/env bash
set -euo pipefail

USER_NAME="hpcuser"
SSH_DIR="/home/${USER_NAME}/.ssh"
KEY_SRC="/run/cluster-keys"

echo "[entrypoint] node=$(hostname) role=${NODE_ROLE:-unknown}"

ssh-keygen -A

if [[ ! -f "${KEY_SRC}/id_ed25519" || ! -f "${KEY_SRC}/id_ed25519.pub" ]]; then
  echo "[entrypoint][ERROR] Key SSH tidak ditemukan di ${KEY_SRC}." >&2
  echo "[entrypoint][ERROR] Jalankan dulu: docker compose run --rm keygen" >&2
  exit 1
fi

install -d -m 700 -o "${USER_NAME}" -g "${USER_NAME}" "${SSH_DIR}"
install    -m 600 -o "${USER_NAME}" -g "${USER_NAME}" "${KEY_SRC}/id_ed25519"     "${SSH_DIR}/id_ed25519"
install    -m 644 -o "${USER_NAME}" -g "${USER_NAME}" "${KEY_SRC}/id_ed25519.pub" "${SSH_DIR}/id_ed25519.pub"
install    -m 600 -o "${USER_NAME}" -g "${USER_NAME}" "${KEY_SRC}/id_ed25519.pub" "${SSH_DIR}/authorized_keys"

mkdir -p /run/sshd

/usr/sbin/sshd -t

echo "[entrypoint] sshd siap dijalankan"
exec /usr/sbin/sshd -D -e