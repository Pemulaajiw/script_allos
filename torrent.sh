#!/bin/bash
clear

IP=$(wget -qO- ipv4.icanhazip.com)
arq="/etc/Plus-torrent"

echo ""
echo -e "\033[1;31m[!]\033[1;33m TORRENT BLOCKER \033[0m"
echo ""

if [[ -e "$arq" ]]; then
    # Fungsi untuk mematikan aturan firewall
    fun_fireoff() {
        iptables -P INPUT ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -t mangle -F
        iptables -t mangle -X
        iptables -t nat -F
        iptables -t nat -X
        iptables -t filter -F
        iptables -t filter -X
        iptables -F
        iptables -X
        rm -f $arq
        sleep 2
    }

    # Fungsi animasi progress
    fun_spn1() {
        fun_fireoff > /dev/null 2>&1 &
        tput civis
        while [ -d /proc/$! ]; do
            for i in / - \\ \|; do
                sleep .1
                echo -ne "\e[1D$i"
            done
        done
        tput cnorm
        echo -e "Ok"
    }

    read -p "Do you want to disable firewall rules? [y/N]: " -e -i n resp
    if [[ "$resp" == "y" ]]; then
        fun_spn1
        echo -e "Torrent blocking successfully removed."
        echo "Returns to menu!"
        sleep 2
        menu
    else
        sleep 1
        menu
    fi

else
    # Fungsi untuk mengaktifkan aturan firewall
    fun_fireon() {
        NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
        cat > $arq <<EOF
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT
iptables -t nat -A PREROUTING -i $NIC -p tcp --dport 6881:6889 -j DNAT --to-dest $IP
iptables -A FORWARD -p tcp -i $NIC --dport 6881:6889 -d $IP -j REJECT
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6889 -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
EOF
        chmod +x $arq
        $arq > /dev/null 2>&1
    }

    fun_spn2() {
        fun_fireon > /dev/null 2>&1 &
        tput civis
        while [ -d /proc/$! ]; do
            for i in / - \\ \|; do
                sleep .1
                echo -ne "\e[1D$i"
            done
        done
        tput cnorm
        echo "Done."
    }

    read -p "Do you want to enable firewall rules? [y/N]: " -e -i n resp
    if [[ "$resp" == "y" ]]; then
        read -p "Confirm your IP to continue: " -e -i $IP IP
        [[ -z "$IP" ]] && { read -p "Enter your IP: " IP; }
        fun_spn2
        echo "Torrent blocking successfully applied."
        sleep 2
        menu
    else
        sleep 1
        menu
    fi
fi