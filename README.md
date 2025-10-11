# 📖 AUTOSCRIPT V2.4

![Auto Script](https://raw.githubusercontent.com/Pemulaajiw/script_allos/main/VpnTunnel.jpg)

---

## 📱 Hubungi Saya

| Platform | Link |
|----------|------|
| Telegram Chat | [![Telegram-chat](https://img.shields.io/badge/Chat-Telegram-blue)](https://t.me/AJW29/) |
| Telegram Grup | [![Telegram-grup](https://img.shields.io/badge/Grup-Telegram-blue)]((https://t.me/Tmpt_Ngobrol)) |
| WhatsApp Chat | [![WhatsApp-Chat](https://img.shields.io/badge/Chat-WhatsApp-green)](https://wa.me/62/87898083051) |

---

## 🖥 Tested OS

- **Debian:** 10 / 11 / 12 / 13  
- **Ubuntu:** 20 / 22 / 24 / 25  

---

## ⚡ Deskripsi

AUTOSCRIPT V2.4 adalah skrip otomatisasi untuk setup server VPN dan tools pendukung di Linux.  
Skrip ini dirancang agar **mudah digunakan**, **cepat diinstal**, dan **stabil di berbagai versi Debian & Ubuntu**.  

---

## 🛠 Fitur

- Instalasi dependencies otomatis  
- Setup environment Python3 & tools tambahan  
- Konfigurasi IPv6 otomatis dinonaktifkan  
- Auto update & upgrade server  
- Install skrip utama dari repository `Pemulaajiw/script`  

---

## 📝 Instalasi (via WGET)

Jalankan perintah berikut di terminal server Anda:

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && \
sysctl -w net.ipv6.conf.default.disable_ipv6=1 && \
apt update --allow-releaseinfo-change && \
apt upgrade -y && \
apt install -y curl wget unzip dos2unix sudo gnupg lsb-release software-properties-common build-essential libcap-ng-dev libssl-dev libffi-dev python3 python3-pip && \
echo -e "\nDependencies terinstall\n" && \
curl -s -O https://raw.githubusercontent.com/Pemulaajiw/script_allos/main/install.sh && \
chmod +x install.sh && \
screen -S install ./install.sh
```
## 💖 Dukung Pengembangan

Bantu saya terus kembangkan proyek ini agar tetap **gratis**, **stabil**, dan **berkembang lebih lanjut** 🚀  
Semua dukungan akan digunakan untuk biaya server, domain, dan pengembangan fitur baru.

<p align="center">
  <img src="https://pemulaajiw.github.io/qr.jpg?raw=true" alt="QRIS Saweria" width="230" height="230">
</p>

> 💬 *Terima kasih banyak untuk setiap dukunganmu. Sedikit dari kamu sangat berarti untuk kelangsungan proyek ini!* 🙏
