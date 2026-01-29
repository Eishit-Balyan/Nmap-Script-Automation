#!/bin/bash

# ethical practises:
# scan only systems you own or have permission for
# random scanning can be illegal and cause trouble

target=$1
scan_type=$2
output="scan.gnmap"

# basic argument check
if [ $# -ne 2 ]; then
    echo "usage: $0 <target> <scan_type>"
    echo "scan types: tcp | udp | version | full | time"
    exit 1
fi

echo "target: $target"
echo "scan type: $scan_type"

# choose scan based on user input
# different scans exist for different purposes

case "$scan_type" in

    tcp)
        # TCP SYN scan
        # sends SYN packets only (half open scan)
        # fast and commonly used as first scan
        # needs root privileges
        echo "running TCP SYN scan"
        sudo nmap -sS -T3 -oG $output $target
        ;;

    udp)
        # UDP scan
        # used to find UDP services like DNS, SNMP etc
        # very slow compared to TCP scans
        echo "running UDP scan (can take time)"
        sudo nmap -sU -T3 -oG $output $target
        ;;

    version)
        # service and version detection
        # helps identify software versions
        # useful for vulnerability discovery
        echo "running version detection scan"
        nmap -sV -T3 -oG $output $target
        ;;

    full)
        # full port scan
        # scans all 65535 TCP ports
        # useful when services run on uncommon ports
        echo "running full port scan"
        sudo nmap -p- -T3 -oG $output $target
        ;;

    time)
        # timing scan
        # -T4 makes scan faster but noisier
        # more likely to be detected
        echo "running fast timing scan"
        sudo nmap -T4 -oG $output $target
        ;;

    *)
        echo "invalid scan type"
        exit 1
        ;;
esac

echo "scan finished"
echo "checking open ports"

# parse grepable nmap output
# only open ports are considered

grep "Ports:" $output | tr ',' '\n' | while read line
do
    port=$(echo $line | cut -d'/' -f1)
    state=$(echo $line | cut -d'/' -f2)

    if [ "$state" = "open" ]; then
        echo "open port found: $port"

        if [ "$port" = "80" ]; then
            echo "http service detected"
            echo "you can try dirsearch on http://$target"
        fi

        if [ "$port" = "443" ]; then
            echo "https service detected"
            echo "you can try sslscan on $target:443"
        fi

        if [ "$port" = "21" ]; then
            echo "ftp service detected"
            echo "running ftp related nmap scripts"
            sudo nmap --script ftp-* -p 21 $target
        fi
    fi
done

rm -f $output

echo "script finished, review results manually"
