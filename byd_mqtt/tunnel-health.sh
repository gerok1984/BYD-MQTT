#!/bin/sh

tunnel_notice_id=byd_mqtt_tunnel_down
tunnel_notice_state=
tunnel_failures=0

set_tunnel_notice() {
    local state="$1" message="${2:-}" payload action
    [ "$state" != "$tunnel_notice_state" ] || return 0
    if [ "$state" = down ]; then
        echo "BYD MQTT: $message"
        action=create
        payload=$(jq -nc --arg id "$tunnel_notice_id" --arg message "$message" \
            '{notification_id: $id, title: "BYD MQTT · Tailscale", message: $message}')
    else
        action=dismiss
        payload=$(jq -nc --arg id "$tunnel_notice_id" '{notification_id: $id}')
    fi
    if [ -z "${SUPERVISOR_TOKEN:-}" ] || ha_notification "$action" "$payload"; then
        tunnel_notice_state=$state
    fi
}

probe_websocket() {
    # An open WebSocket may reach the timeout after returning HTTP 101.
    curl --silent --http1.1 --max-time 6 --output /dev/null \
        --write-out '%{http_code} (curl %{exitcode}: %{errormsg})' \
        --header 'Connection: Upgrade' --header 'Upgrade: websocket' \
        --header 'Sec-WebSocket-Version: 13' \
        --header 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
        --header 'Sec-WebSocket-Protocol: mqtt' \
        "$1" || true
}

check_tunnel() {
    local status local_status
    status=$(probe_websocket "https://$dns_name/mqtt")
    if [ "${status%% *}" = 101 ]; then
        tunnel_failures=0
        set_tunnel_notice up
    else
        tunnel_failures=$((tunnel_failures + 1))
        if [ "$tunnel_failures" -eq 3 ]; then
            local_status=$(probe_websocket http://127.0.0.1:8080/mqtt)
            echo "BYD MQTT: WebSocket público: HTTP $status. WebSocket local: HTTP $local_status."
        fi
        if [ "$tunnel_failures" -ge 3 ]; then
            set_tunnel_notice down "El endpoint MQTT público de Tailscale no responde. Revisa Funnel, Mosquitto y el registro del complemento. / The public Tailscale MQTT endpoint is unavailable. Check Funnel, Mosquitto and the add-on log."
        fi
    fi
}
