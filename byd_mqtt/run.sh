#!/bin/sh
set -eu
umask 077

. /usr/local/bin/expiry.sh
. /usr/local/bin/tunnel-health.sh

mode=$(jq -r '.mode // "tailscale"' /data/options.json)
if [ "$mode" = emqx ]; then
    set_tunnel_notice up
    exec python3 /usr/local/bin/emqx_bridge.py
fi

if [ "$(jq -r '.publish // false' /data/options.json)" != true ]; then
    echo "Publicación desactivada. Configura Tailscale y activa publish para publicar /mqtt."
    set_tunnel_notice up
    exit 0
fi

socket=/run/dolphin-tailscale.sock
auth_file=/run/dolphin-tailscale-auth
tailscale_pid=
nginx_pid=

ts() {
    tailscale --socket="$socket" "$@"
}

cleanup() {
    if [ -n "$nginx_pid" ]; then kill "$nginx_pid" 2>/dev/null || true; fi
    if [ -n "$tailscale_pid" ]; then kill "$tailscale_pid" 2>/dev/null || true; fi
    rm -f "$auth_file"
}

on_exit() {
    local code="$1"
    if [ "$code" -ne 0 ]; then
        tunnel_notice_state=
        set_tunnel_notice down "El túnel MQTT de Tailscale se ha detenido o no ha podido iniciarse. Consulta el registro del complemento. / The Tailscale MQTT tunnel stopped or failed to start. Check the add-on log."
    fi
    cleanup
}

trap 'on_exit $?' EXIT
trap 'exit 0' INT TERM

# Conserva la identidad existente y da a Tailscale una ruta para los certificados TLS.
state_dir=/data/tailscale
mkdir -p "$state_dir"
tailscaled --tun=userspace-networking --socket="$socket" \
    --statedir="$state_dir" --state=/data/tailscaled.state &
tailscale_pid=$!
attempt=0
until ts status --json >/run/dolphin-tailscale-status; do
    # El demonio puede responder con JSON y un código distinto de cero sin sesión.
    if jq -e '.BackendState != null' /run/dolphin-tailscale-status >/dev/null 2>&1; then break; fi
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 15 ] || ! kill -0 "$tailscale_pid" 2>/dev/null; then
        echo "El demonio de Tailscale no está disponible."
        exit 1
    fi
    sleep 1
done

case "$(jq -r .BackendState /run/dolphin-tailscale-status)" in
    Running|Starting)
        ts up --accept-dns=false --hostname=dolphin-mqtt --timeout=45s
        ;;
    *)
        jq -r '.tailscale_auth_key // ""' /data/options.json >"$auth_file"
        if ! [ -n "$(cat "$auth_file")" ]; then
            echo "Introduce una clave de registro de Tailscale en tailscale_auth_key."
            exit 1
        fi
        ts up --accept-dns=false --hostname=dolphin-mqtt --auth-key="file:$auth_file" --timeout=45s
        rm -f "$auth_file"
        ;;
esac

nginx -t
nginx -g 'daemon off;' &
nginx_pid=$!
ts funnel --bg --yes http://127.0.0.1:8080

dns_name=$(ts status --json | jq -er '.Self.DNSName | trimstr(".") | select(length > 0)')
echo "URL MQTT del Dolphin: wss://$dns_name/mqtt (puerto 443)."
echo "Usa las credenciales MQTT de Mosquitto. Comprueba la conexión desde fuera de la red."

next_expiry_check=0
next_health_check=0
while kill -0 "$tailscale_pid" 2>/dev/null && kill -0 "$nginx_pid" 2>/dev/null; do
    now=$(date +%s)
    if [ "$now" -ge "$next_expiry_check" ]; then
        check_node_expiry
        next_expiry_check=$((now + 3600))
    fi
    if [ "$now" -ge "$next_health_check" ]; then
        check_tunnel
        next_health_check=$((now + 30))
    fi
    sleep 2
done
echo "Se ha detenido Tailscale o el proxy MQTT."
exit 1
