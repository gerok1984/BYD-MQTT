FROM alpine:3.23
RUN apk add --no-cache ca-certificates coreutils curl jq nginx tailscale py3-paho-mqtt
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /usr/local/bin/run.sh
COPY funnel.sh expiry.sh tunnel-health.sh emqx_bridge.py /usr/local/bin/
RUN chmod 0755 /usr/local/bin/run.sh
CMD ["/usr/local/bin/run.sh"]
