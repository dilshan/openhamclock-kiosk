#!/bin/bash
# Args: $1=RELEASE  $2=LINUXFAMILY  $3=BOARD  $4=BUILD_DESKTOP
RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
set -e

echo ">>> [customize] board=${BOARD} release=${RELEASE}"

apt-get update -qq
apt-get install -y --no-install-recommends \
    xserver-xorg \
    x11-xserver-utils \
    xinit \
    openbox \
    chromium \
    fonts-noto \
    unclutter \
    network-manager \
    wireless-tools \
    wpasupplicant \
    rfkill \
    ca-certificates \
    curl \
    alsa-utils

mkdir -p /etc/xdg/openbox
cp /tmp/overlay/openbox-autostart /etc/xdg/openbox/autostart
chmod 644 /etc/xdg/openbox/autostart

mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOF

cat >> /root/.bash_profile << 'PROFILE'

if [[ -z "$DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    exec startx -- -nocursor 2>/tmp/xsession.log
fi
PROFILE

mkdir -p /etc/NetworkManager/conf.d/
cp /tmp/overlay/99-wifi-powersave.conf \
    /etc/NetworkManager/conf.d/99-wifi-powersave.conf

mkdir -p /etc/chromium
cp /tmp/overlay/chromium-flags.conf /etc/chromium/chromium.flags

systemctl enable NetworkManager

systemctl disable bluetooth 2>/dev/null || true
systemctl disable avahi-daemon 2>/dev/null || true

echo "consoleblank=0" >> /boot/armbianEnv.txt

mkdir -p /root/.config/chromium/Default

mkdir -p /etc/NetworkManager/system-connections/

# 1. Set WiFi SSID and password.
cat > /etc/NetworkManager/system-connections/mainwifi.nmconnection << 'EOF'
[connection]
id=mainwifi
type=wifi
autoconnect=true

[wifi]
ssid=SSID
mode=infrastructure

[wifi-security]
key-mgmt=wpa-psk
psk=WIFI-PASSWORD

[ipv4]
method=auto

[ipv6]
method=auto
EOF

chmod 600 /etc/NetworkManager/system-connections/mainwifi.nmconnection

# 2. Set root password: "hamclock" (change this!)
#    Generate your own with: openssl passwd -6 "yourpassword"
echo 'root:$6$XRXaRL/xiJhgNKY4$HajiV6KlEKDAFZWko2i.xclYkTHr8HwhZ6tZb30V0QMbm6FE4KvqhNdGlQxbHl8vzbDrAkSkyZo5yHU8PrZFu1' | chpasswd -e

# 3. Set system timezone
ln -sf /usr/share/zoneinfo/Asia/Colombo /etc/localtime

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/default/locale

# 4. Set hostname
echo "hamclock" > /etc/hostname
sed -i 's/127.0.1.1.*/127.0.1.1\thamclock/' /etc/hosts

ssh-keygen -A

systemctl disable armbian-firstrun 2>/dev/null || true
rm -f /root/.not_logged_in_yet

echo "overlayroot=tmpfs" >> /boot/armbianEnv.txt

echo ">>> [customize]Done."
