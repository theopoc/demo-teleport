#!/bin/bash
set -e

echo "[mysql-init] Configuration MySQL pour Teleport..."

# Attendre que MySQL soit prêt
until sudo systemctl is-active --quiet mysql; do
  sleep 2
done
sleep 5

# Créer les utilisateurs MySQL
sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'alice'@'%' IDENTIFIED BY 'alice-password';
CREATE USER IF NOT EXISTS 'teleport_admin'@'%' REQUIRE X509;
GRANT ALL PRIVILEGES ON *.* TO 'alice'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'teleport_admin'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS labdb;
USE labdb;
CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO messages (message) VALUES ('Bonjour depuis Teleport Lab !');
FLUSH PRIVILEGES;
EOF

echo "[mysql-init] MySQL configuré"
