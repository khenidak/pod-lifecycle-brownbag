#!/bin/bash

ns_name="super_ns"


## sets up the network namespace 
## for the two containers
echo "** adding namespace ${ns_name}"
sudo ip netns add ${ns_name}

echo "** adding veth pair one in default ns, on in the other network namespace"
sudo ip link add dev c type veth peer name v_c
sudo ip link set v_c netns ${ns_name}
sudo ip netns exec ${ns_name} ip link set v_c name eth0

echo "** bridging.."
sudo brctl addbr lifecycle #add the bridge
sudo brctl addif lifecycle c # add the interface
sudo ip link set c up

echo "** brining up the interfaces"
sudo ip addr add 172.0.0.3/24 dev lifecycle
sudo ip link set dev lifecycle up


sudo ip netns exec ${ns_name} ip addr add 172.0.0.4/24 dev eth0
sudo ip netns exec ${ns_name} ip link set dev lo up
sudo ip netns exec ${ns_name} ip link set dev eth0 up
sudo ip netns exec ${ns_name} ip route add default via 172.0.0.3


echo "** net namespace setup done"

echo "** setting up iptables"
sudo iptables -t nat -A POSTROUTING -s 172.0.0.0/24 -j MASQUERADE
sudo iptables -t filter -A FORWARD -o lifecycle -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t filter -A FORWARD -i lifecycle ! -o lifecycle -j ACCEPT


# excercise to route traffic from external network (including host net) to 
# container net is left to reader.. hint hint dnat host port to container ip:port +
# makesure that container ip is routable from host net via the bridge.
