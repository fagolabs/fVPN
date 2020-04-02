OpenVPN Performance Benchmark
---

# Performance Criteria
1. Throughput
There are a number of factors affecting throughput:
	- number of clients
	- bandwidth per client
	- encryption algorithms/ciphers
	- compression
	- packet size
	- transport protocol (TCP/UDP)
	- network errors
	- others factors, which?

There are a few specific questions that need an answer (feel free to add more):
	- Maximum throughput using various parameters
	- How does (excessive) packet loss affect performance?
	- Does number of clients affect performance, if data transfer rate remains the same? (or "non-linear resource consumption growth")

2. The network latency between the two ends of the tunnel

3. Maximum supported connections & concurrent connections

# Benchmark model to test (theoretical) throughput:

1. generate secret:
	openvpn --genkey --secret /tmp/secret
2. Test OpenVPN speed:
	time openvpn --test-crypto --secret /tmp/secret --verb 0 --tun-mtu 20000 --cipher aes-256-cbc
3. Your VPN performance is:
	( 3200 / execution_time_seconds ) = Projected Maximum OpenVPN Performance in Mbps﻿
 

For my RT-AC87U router it gives 70s, meaning 45Mbps; for my pfSense Celeron C3150 box it gives 25s, meaning 126Mbps. Both values are actually pretty much identical with real client/server tests I did some time ago. Of course this formula is true to the some degree, where actually NIC performance starts to play role. However for casual, quick and dirty checks this seems very interesting.

# SSL Offload solution for OpenVPN
1. Security in OpenVPN
*Does OpenVPN support IPSec or PPTP?*
	- There are three major families of VPN implementations in wide usage today: SSL, IPSec, and PPTP. OpenVPN is an SSL VPN and as such is not compatible with IPSec, L2TP, or PPTP.
	- The IPSec protocol is designed to be implemented as a modification to the IP stack in kernel space, and therefore each operating system requires its own independent implementation of IPSec.
	- By contrast, OpenVPN's user-space implementation allows portability across operating systems and processor architectures, firewall and NAT-friendly operation, dynamic address support, and multiple protocol support including protocol bridging.
	- There are advantages and disadvantages to both approaches. The principal advantages of OpenVPN's approach are portability, ease of configuration, and compatibility with NAT and dynamic addresses. The learning curve for installing and using OpenVPN is on par with that of other security-related daemon software such as ssh.
	- Historically, one of IPSec's advantages has been multi-vendor support, though that is beginning to change as OpenVPN support is beginning to appear on dedicated hardware devices.
	- While the PPTP protocol has the advantage of a pre-installed client base on Windows platforms, analysis by cryptography experts has revealed security vulnerabilities.

4. Offload solution

# Performance Optimization Solution
1. IPSEC performance without/with Intel DPDK

2. SSL performance without Offload solution 

# Refs
1. https://airvpn.org/forums/topic/18322-how-to-quicly-test-theoretical-openvpn-throughput/
2. https://x3mtek.com/openvpn-performance/
3. https://protectli.com/kb/openvpn-performance/
4. https://hamy.io/post/0003/optimizing-openvpn-throughput/
5. https://community.openvpn.net/openvpn/wiki/PerformanceTesting
6. https://www.net.in.tum.de/fileadmin/bibtex/publications/theses/2018-pudelko-vpn-performance.pdf
7. https://www.giganews.com/vyprvpn/compare-vpn-protocols.html
8. https://github.com/pudelkoM/MoonWire