sudo apt update
sudo apt install nfs-kernel-server -y

# Set up the /nfsshare Directory with permissions
sudo mkdir -p /nfsshare
sudo chown nobody:nogroup /nfsshare
sudo chmod 777 /nfsshare

# Set up /etc/exports
sudo bash -c 'cat >> /etc/exports << EOL
/nfsshare 10.118.0.4/20(rw,async,no_subtree_check)
EOL'

sudo exportfs -ra
sudo exportfs -v

sudo cp  /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server.backup
sudo bash -c 'cat > /etc/default/nfs-kernel-server << EOL
# Runtime priority of server (see nice(1))
RPCNFSDPRIORITY=0
RPCMOUNTDOPTS="--port 20048 --bindip 10.118.0.4"   # Set it to your internal private IP
RPCNFSDOPTS="--nfs-version 4"
RPCNFSDCOUNT=64
EOL'

sudo bash -c 'cat >> /etc/default/nfs-common << EOL
STATDOPTS="--port 32765 --outgoing-port 32766"
EOL'

sudo touch /etc/modprobe.d/lockd.conf
sudo bash -c 'cat >> /etc/modprobe.d/lockd.conf << EOL
options lockd nlm_udpport=32769 nlm_tcpport=32769
EOL'

# Verify firewall and allow NFS if active. We are using Droplet Firewall rules instead.
# sudo ufw status
# sudo ufw allow from 10.118.0.4/20 to any port nfs
# sudo ufw allow 20048/tcp
# sudo ufw allow 32765:32769/tcp


sudo systemctl restart nfs-kernel-server

