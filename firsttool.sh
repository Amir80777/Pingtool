#!/bin/bash
TARGET=""
RESULTS_DIR="results"
 if ! command -v  ping &> /dev/null; then
echo "[-] Xatolik: 'ping'  buyrug'i tizimda topilmadi! "
	exit 1
 fi 
ping_host() {
 	local ip_or_domain="$1"
 if [[ -z "$ip_or_domain" ]]; then
    echo -e "\n[!]Ogohlantirish : Avval Target (IP/Domen) kiriting! "
   return 1
 fi
    echo -e "\n=== Ping Tekshiruvi ==="
    echo "Target: $ip_or_domain"
	local ping_output
	ping_output=$(ping -c 3 -W 2 "$ip_or_domain" 2>/dev/null)
 if [[ $? -eq 0 ]]; then
    echo "[✅] Host TIRIK! "
	local avg_rtt
	avg_rtt=$(echo "$ping_output" | awk -F '/' '/rtt|minavgmax/{print $5}')
    echo "[+]O'rtacha RTT: ${avg_rtt}ms"
   else
    echo "[-] TIRIK yoki JAVOB BERMADI"
 fi 
} 
   
port_scan()  {
 local ip="$1"
    if [[ -z "$ip" ]]; then 
     echo -e "\n[!] Ogohlantirish: Avval Target (ip) Kiriting! "
   return 1
fi
     echo -e "\n  === Port Skanerlash ==="
             local ports=(21 22 23 25 53 80 443 445 3306 3389)
             local open_count=0
             local closed_count=0
     printf  "%-10s %-10s %-10s\n" "PORT" "SERVIS" "HOLAT"
     printf "%-10s %-10s %-10s\n" "----" "------" "-----"

             local port
    	     for port in "${ports[@]}"; do 
             local service="Unknown"
        case $port in
            21) service="FTP" ;;
            22) service="SSH" ;;
            23) service="Telnet" ;;
            25) service="SMTP" ;;
            53) service="DNS" ;;
            80) service="HTTP" ;;
            443) service="HTTPS" ;;
           445) service="SMB" ;;
           3306) service="MySQL" ;;
           3389) service="RDP" ;;
        esac

        # /dev/tcp orqali portni tekshirish (1 sekund timeout)
 if timeout 1 bash -c "true < /dev/tcp/$ip/$port" 2>/dev/null; then
            printf "%-10s %-10s %-10s\n" "$port" "$service" "OPEN"
            open_count=$((open_count + 1))
        else
            printf "%-10s %-10s %-10s\n" "$port" "$service" "closed"
            closed_count=$((closed_count + 1))
 fi
    done

       echo -e "\n[+] Ochiq: $open_count | Yopiq: $closed_count "
}
   save_report() {
     local ip="$1"
if [[ -z "$ip" ]]; then 
        echo -e  "\n[!] Ogohlantirish: Saqlash uchun nishon aniqlanmagan !"
    return 1
fi 
   mkdir -p "$RESULTS_DIR" 
     local current_date
      current_date=$(date +"%Y-%m-%d")
     local file_name="${RESULTS_DIR}/scan_${ip}_${current_date}.txt"
        echo -e "\n Hisobot tayyorlanmoqda..."
{
        echo "=== PINGTOOL REPORT ==="
        echo "Sana: $(date)"
        echo "Target: $ip"
        echo "-----------------------"
    } >> "$file_name"

    ping_host "$ip" >> "$file_name" 2>&1
    port_scan "$ip" >> "$file_name" 2>&1
        echo "Hisobot saqlandi:  $file_name"
}
if [[ -z  "$1" ]]; then
   while true; do 
        echo -e "\n ==================="
	echo "          PINGTOOL       "
	echo "============================"

        if [[ -z "$TARGET" ]]; then
            echo "Target: (belgilanmagan)"
        else
            echo "Target: $TARGET"
        fi
        echo "-----------------------"
        echo "[1] Host tekshirish (ping)"
        echo "[2] Port skanerlash"
        echo "[3] Hisobotni saqlash"
        echo "[0] Chiqish"
        echo "-----------------------"
        read -p "Tanlovni kiriting: " CHOOSE

        case "$CHOOSE" in
            1)
                if [[ -z "$TARGET" ]]; then
read -p "Target IP/Domen kiriting: " TARGET
                fi
                ping_host "$TARGET"
                ;;
            2)
                if [[ -z "$TARGET" ]]; then
                    read -p "Target IP kiriting: " TARGET
                fi
                port_scan "$TARGET"
                ;;
            3)
                save_report "$TARGET"
                ;;
            0)
                echo "Dastur tugatildi."
                break
                ;;
            *)
                echo "[!] Noto'g'ri tanlov qildingiz ! Qayta urinib ko'ring."
                ;;
        esac
        read -p $'\n Davom etish uchun Enterni bos...'
      clear
	done 
else
 	 TARGET="$1"
    	 ping_host "$TARGET"
   	 port_scan "$TARGET"
   	 save_report "$TARGET"
fi
