# #!/bin/bash

# # === Mise à jour et installation des outils utiles ===
# apt update -y
# apt upgrade -y
# apt install -y curl wget git vim net-tools htop jq unzip

# # === Installer Teleport Node Agent ===
# curl https://cdn.teleport.dev/install-v16.4.12.sh | bash -s 16.4.12

# teleport start \
#   --roles=node \
#   --token=YOUR_TOKEN_HERE \
#   --auth-server=TELEPORT_PUBLIC_IP:3025


#!/bin/bash
curl https://cdn.teleport.dev/install-v16.4.12.sh | bash -s 16.4.12
teleport start \
  --roles=node \
  --token=YOUR_TOKEN_HERE \
  --auth-server=VIP_KEEPALIVED_IP:3025
