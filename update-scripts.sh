#!/bin/bash
# Update hanya file script menu, tanpa menyentuh service VPN (nginx/haproxy)
# Deploy ke /usr/local/sbin sesuai setup-main.sh (bukan /usr/bin).
DEST=/usr/local/sbin
echo "Sedang mengunduh pembaruan skrip..."
wget -qO /tmp/menu-update.zip "https://github.com/Pemulaajiw/script_allos/main/menu.zip"
if [ $? -ne 0 ]; then
    echo "Gagal mengunduh menu.zip. Abort (layanan VPN aman)."
    rm -f /tmp/menu-update.zip
    exit 1
fi
rm -rf /tmp/menu-extracted
if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip tidak ditemukan, menginstall..."
    apt-get install -y unzip >/dev/null 2>&1 || apt install -y unzip >/dev/null 2>&1
fi
unzip -q -o /tmp/menu-update.zip -d /tmp/menu-extracted/
if [ ! -f /tmp/menu-extracted/menu/menu ]; then
    echo "Ekstraksi gagal (menu/menu tidak ditemukan). Abort."
    rm -rf /tmp/menu-update.zip /tmp/menu-extracted
    exit 1
fi
chmod +x /tmp/menu-extracted/menu/*
mkdir -p "$DEST"
cp -f /tmp/menu-extracted/menu/* "$DEST/"
# Self-update: pastikan versi terbaru script ini ikut tersebar ke VPS lama
wget -qO "$DEST/update-scripts.sh" "https://raw.githubusercontent.com/Pemulaajiw/script_allos/main/update-scripts.sh"
chmod +x "$DEST/update-scripts.sh"
rm -rf /tmp/menu-update.zip /tmp/menu-extracted
echo "Update skrip berhasil! Layanan VPN tetap aman."
