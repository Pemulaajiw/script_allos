#!/bin/bash

# ===== COLORS =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

clear

# ===== HEADER =====
echo -e "${CYAN}========================================${ENDCOLOR}"
echo -e "${CYAN}           USER MANAGEMENT TOOL         ${ENDCOLOR}"
echo -e "${CYAN}========================================${ENDCOLOR}"
echo ""

# ===== Tampilkan Semua User =====
allusers=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)
echo -e "${GREEN}List of users:${ENDCOLOR}"
echo -e "${GREEN}$allusers${ENDCOLOR}"
echo -e "${CYAN}----------------------------------------${ENDCOLOR}"
echo ""

# ===== Hapus User Manual =====
echo -ne "${YELLOW}Enter the name of the user to be deleted (or press Enter to skip): ${ENDCOLOR}"; read username
if [[ ! -z "$username" ]]; then
    while true; do
        read -p "Do you want to delete the user '$username'? (Y/N) " yn
        case $yn in
            [Yy]* )
                if id "$username" &>/dev/null; then
                    if userdel "$username"; then
                        echo -e "${GREEN}User '$username' deleted successfully.${ENDCOLOR}"
                    else
                        echo -e "${RED}Failed to delete user '$username'.${ENDCOLOR}"
                    fi
                else
                    echo -e "${RED}User '$username' does not exist.${ENDCOLOR}"
                fi
                break
                ;;
            [Nn]* )
                echo -e "${YELLOW}Delete cancelled.${ENDCOLOR}"
                break
                ;;
            * )
                echo -e "${RED}Please answer Y or N.${ENDCOLOR}"
                ;;
        esac
    done
fi

echo -e "${CYAN}----------------------------------------${ENDCOLOR}"
echo -e "${CYAN}Checking for expired users...${ENDCOLOR}"

# ===== Cek & Hapus User Expired Otomatis =====
today=$(date +%s)  # tanggal hari ini dalam epoch
for username in $allusers; do
    expire_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | xargs)

    if [[ "$expire_date" == "never" ]]; then
        continue
    fi

    expire_epoch=$(date -d "$expire_date" +%s 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Warning: Cannot parse expiry date for $username${ENDCOLOR}"
        continue
    fi

    if (( expire_epoch < today )); then
        echo -e "${RED}User '$username' has expired. Deleting...${ENDCOLOR}"
        if userdel "$username"; then
            echo -e "${GREEN}User '$username' deleted successfully.${ENDCOLOR}"
        else
            echo -e "${RED}Failed to delete user '$username'.${ENDCOLOR}"
        fi
    fi
done

echo -e "${CYAN}========================================${ENDCOLOR}"
echo -e "Press Enter to return to main menu"; read