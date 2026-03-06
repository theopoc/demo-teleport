#!/bin/bash
set -e

echo "[mysql-init] Configuration MySQL avec TLS pour Teleport..."

# Attendre que MySQL soit prêt
until sudo systemctl is-active --quiet mysql; do
  sleep 2
done
sleep 5

# Créer les utilisateurs MySQL avec authentification par certificat
# REQUIRE SUBJECT force l'utilisation d'un certificat valide
sudo mysql -u root <<EOF
-- Create database and table first
CREATE DATABASE IF NOT EXISTS labdb;
USE labdb;
CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO messages (message) VALUES ('Bonjour depuis Teleport Lab !');

-- Create users with certificate-based authentication
-- These users require a valid Teleport-signed client certificate to connect
CREATE USER IF NOT EXISTS 'alice'@'%' REQUIRE SUBJECT '/CN=alice';
ALTER USER 'alice'@'%' IDENTIFIED BY '';
GRANT ALL ON labdb.* TO 'alice'@'%';

CREATE USER IF NOT EXISTS 'teleport_admin'@'%' REQUIRE SUBJECT '/CN=teleport_admin';
ALTER USER 'teleport_admin'@'%' IDENTIFIED BY '';
GRANT ALL ON *.* TO 'teleport_admin'@'%';

FLUSH PRIVILEGES;
EOF

echo "[mysql-init] MySQL configuré avec TLS - Authentification par certificat activée"
