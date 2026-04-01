#!/bin/bash
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
case "$scan_type" in

    tcp)
        # TCP SYN scan
        echo "running TCP SYN scan"
        sudo nmap -sS -T3 -oG $output $target
        ;;

    udp)
        # UDP scan
        echo "running UDP scan (can take time)"
        sudo nmap -sU -T3 -oG $output $target
        ;;

    version)
        # service and version detection
        echo "running version detection scan"
        nmap -sV -T3 -oG $output $target
        ;;

    full)
        # full port scan
        echo "running full port scan"
        sudo nmap -p- -T3 -oG $output $target
        ;;

    time)
        # timing scan
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
