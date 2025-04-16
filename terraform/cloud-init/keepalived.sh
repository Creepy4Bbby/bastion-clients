#!/bin/bash
apt update -y
apt install -y keepalived

cat <<EOF > /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
  state MASTER
  interface eth0
  virtual_router_id 51
  priority 100
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass password123
  }
  virtual_ipaddress {
    ${module.static_ip.teleport_ip}
  }
}
EOF

systemctl enable keepalived
systemctl restart keepalived
