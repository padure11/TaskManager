#!/bin/bash

# Helper function pentru output on terminal
show_help() {
    echo "Utilizare: $0 [optiuni]"
    echo "Optiuni:"
    echo "  -m, --monitor       Monitorizeaza resursele (ex.: -m 10s)"
    echo "  -p, --process       Operatii cu procese"
    echo "  -c, --config        Schimbare configuratii resurse"
    echo "  -t, --top           Afiseaza top procese (ex.: -t 3)"
    echo "  -k, --kill          Terminare procese (ex.: -k soft, -k hard)"
    echo "  -h, --help          Afiseaza acest mesaj de ajutor"
    echo "  -r, --restart       Restartare proces specific"
    echo "  -l, --log           Afisare loguri sistem in timp real"
    echo "  -u, --usage         Afiseaza utilizarea discului pentru fiecare director"
    exit 0
}

# Monitorizare resurse
monitor_resources() {
    local interval="$1"
    local unit="${interval: -1}"  # (s, m, h)
    local value="${interval%[smh]}"  # valoare numerica

    case $unit in
        s) interval=$value ;;                     # Secunde
        m) interval=$((value * 60)) ;;            # Minute in secunde
        h) interval=$((value * 60 * 60)) ;;       # Ore in secunde
        *) echo "Unitate de timp invalida! Folosește s, m sau h." ; exit 1 ;;
    esac

    echo "Monitorizare resurse la fiecare $interval secunde:"
    while true; do
        echo "RAM:"
        free -h
        echo "Hard Disk:"
        df -h
        echo "CPU:"
        top -bn1 | grep "Cpu(s)"
        echo "Intensitate utilizare retea:"
        ifconfig | grep "RX packets"
        sleep $interval
    done
}


# Operatii resurse liniuta 2.
process_operations() {
    echo "Operatii cu procese:"
    echo "1. Pornire proces nou"
    echo "2. Suspendare proces"
    echo "3. Asteptare terminare procese"
    echo "4. Mutare proces in background/foreground"
    read -p "Alege o optiune: " opt
    case $opt in
        1) read -p "Comanda procesului: " cmd && eval "$cmd &" ;;
        2) read -p "PID proces: " pid && kill -STOP $pid ;;
        3) echo "Asteptare terminare procese..." && wait ;;
        4) read -p "PID proces: " pid && kill -SIGCONT $pid ;;
        *) echo "Optiune invalida!" ;;
    esac
}

# Liniuta 3 -> Schimbare configurare resurse folosind SED.
# 
change_config() {
    echo "Schimbare configuratii resurse"
    echo "1. Swappiness"
    echo "2. Alte setari sysctl"
    read -p "Alege configuratia de modificat: " opt
    case $opt in
        1)
            read -p "Valoare noua pentru swappiness (0-100): " value
            if [[ $value =~ ^[0-9]+$ && $value -ge 0 && $value -le 100 ]]; then
                echo "Modificare swappiness la $value"
                sudo sed -i '/vm.swappiness/c\vm.swappiness='"$value" /etc/sysctl.conf
                sudo sysctl -w vm.swappiness=$value
            else
                echo "Valoare invalida! Selectati o valoare intre 0 si 100"
            fi
            ;;
        2)
            read -p "Nume configuratie: " config
            read -p "Valoare noua: " value
            if [[ $config =~ ^[a-zA-Z0-9_.]+$ ]]; then
                echo "Modificare $config la $value"
                sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak #Backup configuratiei existente
                if grep -q "^$config" /etc/sysctl.conf; then
                    sudo sed -i 's/^'"$config"'.*/'"$config=$value"'/' /etc/sysctl.conf
                else
                    echo "$config=$value" | sudo tee -a /etc/sysctl.conf
                fi
                sudo sysctl -w $config=$value
            else
                echo "Nume de configurare invalid!"
            fi
            ;;
        *)
            echo "Optiune invalida!"
            ;;
    esac
}

# Afisarea primelor X procese in functie de memory usage.
top_processes() {
    local count="$1"
    echo "Top $count procese:"
    ps aux --sort=-%mem | head -n $((count + 1))
}

# Functia necesita PID. 
# Poate fi soft or hard kill.
terminate_processes() {
    local type="$1"
    case $type in
        soft)
            read -p "PID proces: " pid
            sudo kill $pid
            ;;
        hard)
            read -p "PID proces: " pid
            sudo kill -9 $pid
            ;;
        *)
            echo "Tip de terminare necunoscut!"
            ;;
    esac
}

# Restart process -> Face parte din comenzile suplimentare.
restart_process() {
    read -p "PID proces: " pid  #Cerere utilizatorului pid-ul procesului de repornit

    
    cmd=$(ps -o cmd= -p $pid) #Preia comanda procesului pentru a putea reporni procesul
    #Daca nu exista o comanada se afiseaza un mesaj de eroare
    if [ -z "$cmd" ]; then
        echo "PID $pid nu este valid sau procesul nu exista."
        return 1
    fi
		
    echo "Comanda procesului este: $cmd"

    # Opreste procesul
    kill -9 $pid 
    if [ $? -eq 0 ]; then
        echo "Procesul $pid a fost oprit."
    else
        echo "Eroare la oprirea procesului $pid."
        return 1
    fi

    # Repornire proces
    echo "Repornire proces..."
    $cmd &
    if [ $? -eq 0 ]; then
        echo "Procesul a fost repornit cu comanda: $cmd"
    else
        echo "Eroare la repornirea procesului."
        return 1
    fi
}


# Idem cu restart process -> Comanda suplimentara.

show_logs() {
    echo "Afisare loguri sistem in timp real (Ctrl+C pentru oprire):"
    sudo tail -f /var/log/syslog
}

# Idem.
show_disk_usage() {
    echo "Utilizarea discului pe directoare:"
    sudo du -h --max-depth=1 / | sort -h
}

ARGS=$(getopt -o m:pct:k:hrlu --long monitor:,process,config,top:,kill:,help,restart:,log,usage -n "$0" -- "$@")
if [ $? != 0 ]; then
    show_help
fi

if [ $# == 0 ]; then
    show_help
fi

eval set -- "$ARGS"

while true; do
    case "$1" in
        -m|--monitor)
            monitor_resources "$2"
            shift 2
            ;;
        -p|--process)
            process_operations
            shift
            ;;
        -c|--config)
            change_config
            shift
            ;;
        -t|--top)
            top_processes "${2}"
            shift 2
            ;;
        -k|--kill)
            terminate_processes "${2}"
            shift 2
            ;;
        -r|--restart)
            restart_process
            shift
            ;;
        -l|--log)
            show_logs
            shift
            ;;
        -u|--usage)
            show_disk_usage
            shift
            ;;
        -h|--help)
            show_help
            ;;
        --)
            shift
            break
            ;;
        *)
            show_help
            ;;
    esac
done
