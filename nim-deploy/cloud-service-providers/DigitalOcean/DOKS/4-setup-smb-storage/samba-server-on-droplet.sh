# Update the system
sudo apt update
sudo apt upgrade -y

# Install Samba
sudo apt install samba -y

# Create a Samba user group
sudo groupadd smbgroup

# Create a Samba user (replace 'username' with your preferred username)
sudo useradd -m -G smbgroup testuser

# Set the Samba user password (you'll be prompted to enter the password)
sudo smbpasswd -a testuser  # dummy pass testuser123

# Enable the Samba user
sudo smbpasswd -e testuser


# Create a directory for the share
sudo mkdir /mnt/volume_tor1_01/share

# Set appropriate permissions
chown testuser:smbgroup /mnt/volume_tor1_01/share
chmod 770 /mnt/volume_tor1_01/share
#sudo chmod 777 /mnt/volume_tor1_01/share

# Back up the original Samba configuration
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Create a new Samba configuration
sudo bash -c 'cat > /etc/samba/smb.conf << EOL
[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = ubuntu
security = user
map to guest = bad user
dns proxy = no

# Performance settings
write cache size = 2097152
min receivefile size = 16384
getwd cache = true

# Additional performance settings
socket options = TCP_NODELAY IPTOS_LOWDELAY
read raw = yes
write raw = yes
# strict locking = no
strict sync = no

# Network interface binding
interfaces = eth1
bind interfaces only = yes

[share]
path = /mnt/volume_tor1_01/share
valid users = @smbgroup
guest ok = no
writable = yes
browsable = yes
EOL'


# Restart Samba to apply changes
sudo systemctl restart smbd

# Configure firewall to allow Samba traffic
sudo ufw allow 'Samba'

# Reload firewall
sudo ufw reload

# Display Samba user list
sudo pdbedit -L -v

# Test Samba configuration
testparm