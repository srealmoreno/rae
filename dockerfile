FROM ubuntu

WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-suggests --no-install-recommends gpg ca-certificates gpg-agent curl &&\
    echo deb https://deb.frrouting.org/frr bionic frr-stable | tee -a /etc/apt/sources.list.d/frr.list &&\
    curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add - &&\
    sed -i 's:^path-exclude=/usr/share/man:#path-exclude=/usr/share/man:' /etc/dpkg/dpkg.cfg.d/excludes &&\
    apt-get update && env DEBIAN_FRONTEND=noninteractive\
    apt-get install -y --no-install-suggests --no-install-recommends\
    man\
    manpages-posix\
    bind9\
    bridge-utils\
    command-not-found\
    bash-completion\
    dnsutils\
    ethtool\
    frr\
    frr-doc\
    frr-pythontools\
    frr-rpki-rtrlib\
    frr-snmp\
    ifupdown\
    iperf\
    iputils-arping\
    iputils-clockdiff\
    iputils-ping\
    iputils-tracepath\
    isc-dhcp-server\
    isc-dhcp-client\
    isc-dhcp-relay\
    isc-dhcp-common\
    lsof\
    mtr\
    net-tools\
    netcat\
    nmap\
    python3\
    ssh\
    vim\
    nano\
    mcedit\
    tcpdump\
    telnet\
    traceroute\
    vlan\
    whois\
    wget &&\
    apt-get auto-remove &&\
    rm -rf /var/lib/apt/lists/* /etc/apt/apt.conf.d/docker-clean
    
RUN echo "by: Srealmoreno" > .bash_history
RUN sed -i "17,32s/no/yes/" /etc/frr/daemons
RUN sed -i "46s/.//"        /etc/skel/.bashrc 
RUN sed -i "35,41s/.//"     /etc/bash.bashrc
RUN sed -i "39b0; 97,99b0; b ;:0 ;s/.//" .bashrc

CMD [ "bash" ]

#RUN sed -i "60s/32m/31m/; 46s/.//" /etc/skel/.bashrc && cp /etc/skel/.bashrc /root/.bashrc #cambio de color
#RUN sed -i "35,41s/.//" /etc/bash.bashrc




#RUN sed -i "53s/32m/31m/; 39b0; 97,99b0; b ;:0 ;s/.//" .bashrc
##sed -i "60s/32m/31m/; 46b0; 111,117b0; b ;:0 ;s/#//" /etc/skel/.bashrc  ##Por si el bash_completion esta comentado


