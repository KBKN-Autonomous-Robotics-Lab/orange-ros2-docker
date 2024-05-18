while true
do
    sudo ifconfig enp3s0 192.168.1.1
    sudo route add -host 192.168.3.11 gw 192.168.3.1 enp3s0
    sudo route add -host 192.168.3.201 gw 192.168.3.1 enp3s0
    
    sleep 2
done
