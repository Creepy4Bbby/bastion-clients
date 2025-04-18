#!/bin/bash
curl https://cdn.teleport.dev/install-v16.4.12.sh | bash -s 16.4.12
teleport start \
  --roles=node \
  --token= \
  --auth-server=TELEPORT_PUBLIC_IP:3025
