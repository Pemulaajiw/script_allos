#!/bin/bash
# UDP user manager — lengkap & perbaikan parsing tanggal

# ===== WARNA & FORMAT =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[93m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# ===== PATH =====
HOST_FILE="/root/udp/host.conf"
TG_CONF="/root/udp/telegram.conf"
BACKUP_DIR="/root/udp/backup"
OFFSET_FILE="/root/udp/tg_offset.txt"
EXP_FILE="/etc/expuser.conf"

# buat direktori & file dasar
mkdir -p /root/udp "$BACKUP_DIR"
[[ ! -f $OFFSET_FILE ]] && echo "0" > $OFFSET_FILE
[[ ! -f $EXP_FILE ]] && touch $EXP_FILE

# ===== FUNGSI HOST =====
get_host() {
    if [[ -s $HOST_FILE ]]; then
        cat "$HOST_FILE"
    else
        curl -s https://ipecho.net/plain || echo "127.0.0.1"
    fi
}
view_host() {
    local h
    h=$(get_host)
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}🌐 Host Aktif : $h${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}
set_host() {
    echo "$1" > "$HOST_FILE"
    echo -e "${GREEN}✅ Host berhasil diubah: $1${RESET}"
}
reset_host() {
    rm -f "$HOST_FILE"
    echo -e "${GREEN}✅ Host direset, kembali ke IP VPS${RESET}"
}

# ===== FUNGSI USER =====
create_user() {
    local username="$1" password="$2" expire_days="$3" maxlogins="$4"
    local s_ip exp_date

    if id -u "$username" &>/dev/null; then
        echo -e "${RED}⚠ User sudah ada${RESET}"
        return 1
    fi

    s_ip=$(get_host)
    exp_date=$(date -d "+$expire_days days" +"%Y-%m-%d")
    useradd -M -N -s /bin/bash "$username" && echo "$username:$password" | chpasswd
    chage -E "$exp_date" "$username"
    echo "$username hard maxlogins $maxlogins" >/etc/security/limits.d/"$username.conf"

    # update EXP_FILE (hapus entry lama kalau ada, lalu append)
    sed -i "/^$username:/d" "$EXP_FILE"
    echo "$username:$exp_date" >> "$EXP_FILE"

echo -e "${CYAN}═════════════════════════${RESET}"
echo -e "${GREEN}  ✅ AKUN BARU UDP PREMIUM ✅${RESET}"
echo -e "${CYAN}═════════════════════════${RESET}"
echo -e " ${YELLOW}🌐 Host/IP : ${CYAN}$s_ip${RESET}"
echo -e " ${YELLOW}👤 Username : ${CYAN}$username${RESET}"
echo -e " ${YELLOW}🔑 Password : ${CYAN}$password${RESET}"
echo -e " ${YELLOW}⏳ Expired : ${CYAN}$exp_date${RESET}"
echo -e " ${YELLOW}🔒 Max Login : ${CYAN}$maxlogins${RESET}"
echo -e " ${YELLOW}🚀 UDP Config : ${CYAN}$s_ip:1-2025@$username:$password${RESET}"
echo -e "${CYAN}═════════════════════════${RESET}"
}

create_trial() {
    local s_ip username password maxlogins exp_date
    s_ip=$(get_host)

    # username 2 karakter acak
    username=$(tr -dc a-z0-9 </dev/urandom | head -c2)

    # pastikan username unik
    while id "$username" &>/dev/null; do 
        username=$(tr -dc a-z0-9 </dev/urandom | head -c2)
    done

    # password 2 karakter acak
    password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c2)

    maxlogins=20
    exp_date=$(date -d "+1 day" +"%Y-%m-%d")

    # buat user dan set password
    useradd -M -N -s /bin/bash "$username" && echo "$username:$password" | chpasswd
    chage -E "$exp_date" "$username"
    echo "$username hard maxlogins $maxlogins" >/etc/security/limits.d/"$username.conf"

    # simpan ke EXP_FILE
    sed -i "/^$username:/d" "$EXP_FILE"
    echo "$username:$exp_date" >> "$EXP_FILE"

    # tampilkan info
echo -e "${CYAN}═════════════════════════${RESET}"
echo -e "${GREEN}      ⚡ TRIAL UDP PREMIUM ⚡${RESET}"
echo -e "${CYAN}═════════════════════════${RESET}"
echo -e " ${YELLOW}🌐 Host/IP : ${CYAN}$s_ip${RESET}"
echo -e " ${YELLOW}👤 Username : ${CYAN}$username${RESET}"
echo -e " ${YELLOW}🔑 Password : ${CYAN}$password${RESET}"
echo -e " ${YELLOW}⏳ Expired : ${CYAN}$exp_date${RESET}"
echo -e " ${YELLOW}🔒 Max Login : ${CYAN}$maxlogins${RESET}"
echo -e " ${YELLOW}🚀 UDP Config : ${CYAN}$s_ip:1-2025@$username:$password${RESET}"
echo -e "${CYAN}═════════════════════════${RESET}"
}

renew_user() {
    read -p "Username: " username
    read -p "Tambah masa aktif (hari): " tambah
    if [[ -z "$username" || -z "$tambah" ]]; then
        echo -e "${RED}❌ Input tidak lengkap${RESET}"
        return 1
    fi
    if ! id -u "$username" &>/dev/null; then
        echo -e "${RED}❌ User tidak ditemukan${RESET}"
        return 1
    fi

    current_raw=$(chage -l "$username" | awk -F": " '/Account expires/ {print $2}')
    if [[ "$current_raw" == "never" ]]; then
        current_epoch=$(date +%s)
    else
        # hapus koma lalu parse
        current_clean="${current_raw//,/}"
        current_clean="$(echo "$current_clean" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        current_epoch=$(date -d "$current_clean" +%s 2>/dev/null)
        [[ -z "$current_epoch" ]] && current_epoch=$(date +%s)
    fi

    new_epoch=$((current_epoch + (tambah * 86400)))
    new_exp=$(date -d "@$new_epoch" +"%Y-%m-%d")
    chage -E "$new_exp" "$username"

    sed -i "/^$username:/d" "$EXP_FILE"
    echo "$username:$new_exp" >> "$EXP_FILE"
    echo -e "${GREEN}✅ User $username diperpanjang sampai $new_exp${RESET}"
}

delete_user() {
    read -p "Username yang ingin dihapus: " username
    if [[ -z "$username" ]]; then
        echo -e "${RED}❌ Input kosong${RESET}"
        return 1
    fi
    if ! id -u "$username" &>/dev/null; then
        echo -e "${RED}❌ User tidak ditemukan${RESET}"
        return 1
    fi
    userdel -r "$username" 2>/dev/null
    rm -f /etc/security/limits.d/"$username".conf
    sed -i "/^$username:/d" "$EXP_FILE"
    echo -e "${GREEN}✅ User $username berhasil dihapus${RESET}"
}

list_user() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}📋 Daftar User Aktif${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while read -r u; do
        exp=$(chage -l "$u" 2>/dev/null | awk -F": " '/Account expires/ {print $2}')
        [[ -z "$exp" ]] && exp="unknown"
        echo -e "👤 $u : $exp"
    done
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# ===== BACKUP & RESTORE =====
backup_data() {
    mkdir -p "$BACKUP_DIR"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd > "$BACKUP_DIR/users.list"
    > "$BACKUP_DIR/shadow.backup"
    for u in $(cat "$BACKUP_DIR/users.list"); do
        chage -l "$u" | awk -F": " '/Account expires/ {print $2}' > "$BACKUP_DIR/$u.expire"
        grep "^$u:" /etc/shadow >> "$BACKUP_DIR/shadow.backup"
    done
    [[ -f $HOST_FILE ]] && cp "$HOST_FILE" "$BACKUP_DIR/"
    tar -czf /root/udp/backup_ssh.tar.gz -C /root/udp backup || tar -czf /root/udp/backup_ssh.tar.gz -C /root/udp .
    LINK=$(curl -s -F "file=@/root/udp/backup_ssh.tar.gz" https://0x0.st)

    echo -e "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏪 Riswan Store
✅ Backup Berhasil!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 Link Backup :
🎯 $LINK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

restore_data() {
    echo -ne "${YELLOW}Masukkan link backup: ${RESET}"; read link
    [[ -z "$link" ]] && { echo -e "${RED}❌ Link kosong${RESET}"; return 1; }
    wget -qO /root/udp/backup_ssh.tar.gz "$link"
    tar -xzf /root/udp/backup_ssh.tar.gz -C /root/udp/ 2>/dev/null || { echo -e "${RED}❌ Gagal ekstrak backup${RESET}"; return 1; }
    cd /root/udp/backup || return 1

    for u in $(cat users.list 2>/dev/null); do
        [[ ! $(id -u "$u" 2>/dev/null) ]] && useradd -M -N -s /bin/bash "$u"
        shadow_line=$(grep "^$u:" shadow.backup 2>/dev/null)
        [[ -n "$shadow_line" ]] && (sed -i "/^$u:/d" /etc/shadow && echo "$shadow_line" >> /etc/shadow)
        expire=$(cat "$u.expire" 2>/dev/null)
        [[ -n "$expire" && "$expire" != "never" ]] && chage -E "$(date -d "$expire" +"%Y-%m-%d" 2>/dev/null || echo "$expire")" "$u"
    done

    [[ -f host.conf ]] && cp host.conf "$HOST_FILE"

    echo -e "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏪 Riswan Store
✅ Restore Berhasil!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 Sumber Link :
🎯 $link
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ===== AUTO DELETE USER EXPIRED (pakai epoch, tahan koma & spasi) =====
delete_expired_users() {
    echo -e "${YELLOW}🔍 Mengecek user expired...${RESET}"
    today_epoch=$(date +%s)
    count=0
    [[ ! -f $EXP_FILE ]] && touch "$EXP_FILE"
    > /tmp/exp_tmp.txt
    while IFS=":" read -r username exp_date; do
        [[ -z "$username" || -z "$exp_date" ]] && continue
        # hilangkan koma, trim spasi
        exp_clean="${exp_date//,/}"
        exp_clean="$(echo "$exp_clean" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        exp_epoch=$(date -d "$exp_clean" +%s 2>/dev/null)
        [[ -z "$exp_epoch" ]] && continue
        if [[ $today_epoch -ge $exp_epoch ]]; then
            if id -u "$username" &>/dev/null; then
                userdel -r "$username" 2>/dev/null
                rm -f /etc/security/limits.d/"$username".conf
            fi
            echo -e "${RED}⚠ User $username expired ($exp_date) → dihapus otomatis${RESET}"
            ((count++))
        else
            echo "$username:$exp_date" >> /tmp/exp_tmp.txt
        fi
    done < "$EXP_FILE"
    mv /tmp/exp_tmp.txt "$EXP_FILE" 2>/dev/null || true
    echo -e "${GREEN}✅ Total $count user expired dihapus${RESET}"
}

# ===== MANUAL DELETE EXPIRED =====
delete_expired_manual() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}📋 User yang sudah expired${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    today_epoch=$(date +%s)
    expired_list=()

    while IFS=":" read -r username exp_date; do
        [[ -z "$username" || -z "$exp_date" ]] && continue
        exp_clean="${exp_date//,/}"
        exp_clean="$(echo "$exp_clean" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        exp_epoch=$(date -d "$exp_clean" +%s 2>/dev/null)
        [[ -z "$exp_epoch" ]] && continue
        if [[ $today_epoch -ge $exp_epoch ]]; then
            echo -e "👤 $username : $exp_date"
            expired_list+=("$username")
        fi
    done < "$EXP_FILE"

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if [[ ${#expired_list[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ Tidak ada user expired${RESET}"
        return
    fi

    read -p "Masukkan username expired yang ingin dihapus: " userdel_manual
    if id -u "$userdel_manual" &>/dev/null; then
        userdel -r "$userdel_manual" 2>/dev/null
        rm -f /etc/security/limits.d/"$userdel_manual".conf
        sed -i "/^$userdel_manual:/d" "$EXP_FILE"
        echo -e "${GREEN}✅ User $userdel_manual berhasil dihapus manual${RESET}"
    else
        echo -e "${RED}❌ User $userdel_manual tidak ditemukan${RESET}"
    fi
}

# ===== MENU UTAMA =====
menu() {
    delete_expired_users  # cek otomatis saat buka menu
    clear
    echo -e "${YELLOW}╔══════════════════════════════════${RESET}"
    echo -e "${YELLOW}║   🌐 PANEL MANAJEMEN VPS 🌐       ${RESET}"
    echo -e "${YELLOW}╠══════════════════════════════════${RESET}"
    echo -e "${YELLOW}║ 1) Tambah User${RESET}"
    echo -e "${YELLOW}║ 2) Tambah Trial${RESET}"
    echo -e "${YELLOW}║ 3) Perpanjang User${RESET}"
    echo -e "${YELLOW}║ 4) Hapus User${RESET}"
    echo -e "${YELLOW}║ 5) List User Aktif${RESET}"
    echo -e "${YELLOW}║ 6) Host Aktif${RESET}"
    echo -e "${YELLOW}║ 7) Set Host${RESET}"
    echo -e "${YELLOW}║ 8) Reset Host${RESET}"
    echo -e "${YELLOW}║ 9) Backup link${RESET}"
    echo -e "${YELLOW}║ 10) Restore link${RESET}"
    echo -e "${YELLOW}║ 11) Hapus User Expired Manual${RESET}"
    echo -e "${YELLOW}║ 0) Keluar${RESET}"
    echo -e "${YELLOW}╚══════════════════════════════════${RESET}"
    echo ""
    read -p "⚡ Pilih menu [0-11]: " pilih
    case $pilih in
        1) read -p "Username: " u; read -p "Password: " p; read -p "Expired (hari): " e; read -p "Max login: " m; create_user "$u" "$p" "$e" "$m" ;;
        2) create_trial ;;
        3) renew_user ;;
        4) delete_user ;;
        5) list_user ;;
        6) view_host ;;
        7) read -p "Masukkan host/IP: " h; set_host "$h" ;;
        8) reset_host ;;
        9) backup_data ;;
        10) restore_data ;;
        11) delete_expired_manual ;;
        0|"") exit 0 ;;
        *) echo -e "${RED}⚠ Pilihan salah!${RESET}"; sleep 1 ;;
    esac
    echo -e "\nTekan Enter untuk kembali ke menu"; read
    menu
}

# ===== START =====
SCRIPT_PATH="$(realpath "$0")"
chmod +x "$SCRIPT_PATH"

menu