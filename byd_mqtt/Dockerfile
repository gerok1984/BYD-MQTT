FROM alpine:3.23
RUN apk add --no-cache ca-certificates jq nginx tailscale
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /usr/local/bin/run.sh
RUN chmod 0755 /usr/local/bin/run.sh
CMD ["/usr/local/bin/run.sh"]
