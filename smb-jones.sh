#!/bin/bash

# Copyrighted to Jones Joseph
# Script to enable Samba, configure folder sharing with user authentication, and share printers with guest access.
# Operations performed:
# 1. Install Samba and necessary packages.
# 2. Configure Samba to share a folder specified by the user with username "jones" and password "jones".
# 3. Share printers connected to the system with guest access.
# 4. Set up a default shared folder with guest access.
# 5. Ensure Samba service is started and enabled.
# 6. Configure appropriate firewall rules to allow Samba traffic.

# Function to log messages
log_message() {
    local message=$1
    local log_file="/var/log/samba_share_setup.log"
    echo "$(date) - $message" | tee -a "$log_file"
}

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo!" 1>&2
    exit 1
fi

# Install Samba and necessary packages
log_message "Installing Samba and necessary packages..."
apt update
apt install -y samba samba-common-bin cups samba-client system-config-printer

# Enable and start the Samba service
log_message "Starting and enabling Samba service..."
systemctl enable smbd
systemctl start smbd

# Check if Samba is running
if systemctl is-active --quiet smbd; then
    log_message "Samba service is running."
else
    log_message "Failed to start Samba service. Exiting script."
    exit 1
fi

# Ask the user for the folder they want to share
echo "Enter the full path of the folder you want to share:"
read -r share_folder

# Validate folder exists
if [ ! -d "$share_folder" ]; then
    log_message "The folder $share_folder does not exist. Exiting script."
    echo "The folder does not exist. Exiting script."
    exit 1
fi

# Ask the user for the share name
echo "Enter a name for the Samba share (this will be the name displayed to clients):"
read -r share_name

# Ask the user for permissions on the share (read/write or read-only)
echo "Do you want the share to be read/write or read-only? (Enter 'rw' or 'ro')"
read -r share_permission

if [[ "$share_permission" != "rw" && "$share_permission" != "ro" ]]; then
    log_message "Invalid permission selected. Exiting script."
    echo "Invalid permission. Please enter 'rw' for read/write or 'ro' for read-only."
    exit 1
fi

# Create the Samba user 'jones' with the password 'jones' if it doesn't exist
log_message "Creating Samba user 'jones' with password 'jones'..."
if ! pdbedit -L | grep -q "^jones$"; then
    (echo "jones"; echo "jones") | smbpasswd -a jones
    smbpasswd -e jones
    log_message "Samba user 'jones' created."
else
    log_message "Samba user 'jones' already exists."
fi

# Configure the Samba share
log_message "Configuring Samba share for folder: $share_folder"

# Backup the original Samba configuration file
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Add the share configuration to smb.conf
echo "
[$share_name]
    path = $share_folder
    browseable = yes
    read only = no
    guest ok = no
    valid users = jones
" >> /etc/samba/smb.conf

# Apply the configuration by restarting Samba service
systemctl restart smbd

# Set appropriate permissions for the shared folder
if [ "$share_permission" == "rw" ]; then
    chmod -R 775 "$share_folder"
    log_message "Set read/write permissions on $share_folder."
else
    chmod -R 755 "$share_folder"
    log_message "Set read-only permissions on $share_folder."
fi

# Configure default Samba shared folder with guest access (public folder)
log_message "Configuring default Samba share (public folder) with guest access..."

echo "
[public]
    path = /srv/samba/public
    browseable = yes
    read only = no
    guest ok = yes
    create mask = 0775
" >> /etc/samba/smb.conf

# Create the public folder if it doesn't exist
mkdir -p /srv/samba/public
chmod -R 0775 /srv/samba/public
log_message "Public folder created at /srv/samba/public."

# Configure printer sharing with guest access
log_message "Configuring printer sharing with guest access..."

echo "
[printers]
    comment = All Printers
    path = /var/spool/samba
    printable = yes
    browseable = no
    guest ok = yes
    read only = yes
    create mode = 0700
" >> /etc/samba/smb.conf

# Restart Samba service to apply changes
systemctl restart smbd

# Ensure CUPS is enabled for printer sharing
log_message "Starting and enabling CUPS service..."
systemctl enable cups
systemctl start cups

# Check if CUPS is running
if systemctl is-active --quiet cups; then
    log_message "CUPS service is running."
else
    log_message "Failed to start CUPS service."
    exit 1
fi

# Add firewall rules to allow Samba traffic
log_message "Configuring firewall to allow Samba traffic..."
ufw allow samba

# Display current Samba share configuration
log_message "Samba shares currently configured:"
smbclient -L localhost -U%

# Display the status of Samba and CUPS services
log_message "Displaying Samba service status:"
systemctl status smbd

log_message "Displaying CUPS service status:"
systemctl status cups

# Final status
log_message "Samba and printer sharing setup complete."

# Output final summary for user
echo "Samba has been configured with the following details:"
echo "Share name: $share_name"
echo "Folder to share: $share_folder"
echo "Permissions: $share_permission"
echo "Printer sharing has been enabled."
echo "Check the log file at /var/log/samba_share_setup.log for more details."
