# TCPDUMP

## Only Capture SYN or ACK

~~~bash

$ tcpdump -i <interface> "tcp[tcpflags] & (tcp-syn) != 0"
$ tcpdump -i <interface> "tcp[tcpflags] & (tcp-ack) != 0"
$ tcpdump -i <interface> "tcp[tcpflags] & (tcp-fin) != 0"
$ tcpdump -r <interface> "tcp[tcpflags] & (tcp-syn|tcp-ack) != 0"

~~~
