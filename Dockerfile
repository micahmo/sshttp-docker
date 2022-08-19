# Build:  docker build -f Dockerfile . -t ghcr.io/micahmo/sshttp-docker
# Run:    docker run --cap-add=NET_ADMIN -v /lib/modules:/lib/modules -e SSH_PORT=22 -e HTTP_PORT=443 -e LOCAL_PORT=1234 -e SERVICE_PORT=80 -t sshttp-docker ghcr.io/micahmo/sshttp-docker

# Build layer
FROM debian as build

# Install Git
RUN apt update
# For build tools
RUN apt install git make g++ -y
# For <sys/capability.h>
RUN apt install libcap-dev -y

# Clone upstream
WORKDIR /usr/local/src
RUN git clone https://github.com/stealth/sshttp

# Build
WORKDIR /usr/local/src/sshttp
RUN make
RUN sed -i "s/nf_conntrack_ipv4/nf_conntrack/" nf-tproxy # TODO?

# Final layer
FROM debian as final

RUN apt update
# For ip
RUN apt install iproute2 -y
# For iptables
RUN apt install iptables -y
# For modprobe
RUN apt install kmod -y
# For chroot
RUN apt install coreutils -y

# Copy build output
COPY --from=build ["/usr/local/src/sshttp/sshttpd", "/app/sshttpd"]
COPY --from=build ["/usr/local/src/sshttp/nf-tproxy", "/app/nf-tproxy"]
COPY ["start.sh", "app/start.sh"]
RUN chmod +x /app/start.sh

RUN mkdir /var/empty
#RUN depmod

ENTRYPOINT [ "sh", "-c", "/app/start.sh" ]
