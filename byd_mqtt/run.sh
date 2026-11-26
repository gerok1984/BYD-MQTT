#!/bin/sh
set -eu
umask 077

. /usr/local/bin/expiry.sh
. /usr/local/bin/tunnel-health.sh

options=/data/options.json
mode=$(jq -r '.mode // "tailscale"' "$options")
publish=$(jq -r '.publish // false' "$options")

case "$mode:$publish" in
    emqx:*|both:false)
        echo "BYD MQTT: modo EMQX Cloud."
        if [ "$mode" = both ]; then
            echo "BYD MQTT: activa publish para iniciar también Tailscale Funnel."
        fi
        set_tunnel_notice up
        exec python3 /usr/local/bin/emqx_bridge.py
        ;;
    tailscale:true)
        exec sh /usr/local/bin/funnel.sh
        ;;
    tailscale:false)
        echo "Publicación desactivada. Configura Tailscale y activa publish para publicar /mqtt."
        set_tunnel_notice up
        exit 0
        ;;
    both:true)
        echo "BYD MQTT: modo Tailscale Funnel + EMQX Cloud (beta)."
        ;;
    *)
        echo "BYD MQTT: modo o configuración de publicación inválidos."
        exit 1
        ;;
esac

funnel_pid=
bridge_pid=
stop_children() {
    for pid in "$funnel_pid" "$bridge_pid"; do
        if [ -n "$pid" ]; then kill "$pid" 2>/dev/null || true; fi
    done
    wait || true
}
trap stop_children EXIT
trap 'exit 0' INT TERM

next_funnel=0
next_bridge=0
while :; do
    now=$(date +%s)
    if [ "$now" -ge "$next_funnel" ] && { [ -z "$funnel_pid" ] || ! kill -0 "$funnel_pid" 2>/dev/null; }; then
        wait "$funnel_pid" 2>/dev/null || true
        sh /usr/local/bin/funnel.sh &
        funnel_pid=$!
        next_funnel=$((now + 30))
    fi
    if [ "$now" -ge "$next_bridge" ] && { [ -z "$bridge_pid" ] || ! kill -0 "$bridge_pid" 2>/dev/null; }; then
        wait "$bridge_pid" 2>/dev/null || true
        python3 /usr/local/bin/emqx_bridge.py &
        bridge_pid=$!
        next_bridge=$((now + 30))
    fi
    sleep 2
done
