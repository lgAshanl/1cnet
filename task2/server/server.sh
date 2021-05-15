#!/bin/bash

# СБРОС ПРАВИЛ  -----------------------------
#tc qdisc del dev eth0 root 
#tc qdisc del dev eth0 ingress

ip link add dev ifb0 type ifb
ip link set dev ifb0 up

tc qdisc add dev eth0 handle ffff: ingress
tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb0
tc qdisc add dev ifb0 root handle 1:0 htb default 1

tc filter add dev ifb0 protocol ip parent 1:0 prio 1 u32 match ip protocol 1 0xff action drop
tc filter add dev ifb0 protocol ip parent 1:0 prio 1 u32 match ip src 88.88.3.0/24 match ip protocol 6 0xff match ip dport 22 0xffff action drop



tc qdisc add dev eth0 root handle 1: htb default 11
tc class add dev eth0 parent 1:0 classid 1:1 htb rate 100mbit prio 1

tc class add dev eth0 parent 1:1 classid 1:11 htb rate 5mbit ceil 40mbit prio 1

tc class add dev eth0 parent 1:1 classid 1:12 htb rate 5mbit ceil 20mbit prio 1
tc class add dev eth0 parent 1:1 classid 1:121 htb rate 5mbit ceil 20mbit prio 2

tc class add dev eth0 parent 1:1 classid 1:13 htb rate 5mbit ceil 20mbit prio 1

tc class add dev eth0 parent 1:1 classid 1:14 htb rate 5mbit ceil 20mbit prio 1



tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 88.88.1.0/24 flowid 1:11

tc filter add dev eth0 parent 1:0 protocol ip prio 2 u32 match ip dst 88.88.2.0/24 match ip protocol 17 0xff flowid 1:121
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 88.88.2.0/24 flowid 1:12

tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 88.88.3.0/24 flowid 1:13

tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 88.88.4.0/24 flowid 1:14

service ssh start

while true; do
    iperf -c 88.88.1.1    -p 8080 -t 1 -e
    iperf -c 88.88.1.1 -u -p 8080 -t 1 -e

    iperf -c 88.88.2.2    -p 8080 -t 1 -e
    iperf -c 88.88.2.2 -u -p 8080 -t 1 -e

    iperf -c 88.88.3.3    -p 8080 -t 1 -e
    iperf -c 88.88.3.3 -u -p 8080 -t 1 -e

    iperf -c 88.88.4.4    -p 8080 -t 1 -e
    iperf -c 88.88.4.4 -u -p 8080 -t 1 -e
done