#!/bin/bash
set -e

echo "[init] Attente de l'accessibilité de tctl..."
until sudo tctl status &>/dev/null; do
  sleep 2
done
echo "[init] tctl prêt"

# Créer le rôle RBAC
if sudo tctl create /etc/teleport/lab-role.yaml 2>/dev/null; then
  echo "[init] Rôle lab-access créé"
else
  echo "[init] Rôle lab-access déjà existant"
fi

# Créer l'utilisateur admin (une seule fois)
if ! sudo tctl users list 2>/dev/null | grep -q admin; then
  echo "[init] Création de l'utilisateur admin..."
  sudo tctl users add teleport-admin \
    --roles=editor,access,lab-access \
    --logins=root 2>&1 | tee /tmp/admin-invite.txt
  cat /tmp/admin-invite.txt
else
  echo "[init] Utilisateur teleport-admin déjà existant"
fi
