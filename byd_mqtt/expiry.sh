#!/bin/sh

expiry_notice_state=
expiry_notice_id=byd_mqtt_tailscale_key_expiry
expiry_notice_days=14

expiry_notification() {
    local action="$1" payload="$2"
    printf 'Authorization: Bearer %s\n' "$SUPERVISOR_TOKEN" |
        curl --silent --fail --max-time 5 --header @- \
            --header 'Content-Type: application/json' --data "$payload" \
            "http://supervisor/core/api/services/persistent_notification/$action" >/dev/null
}

check_node_expiry() {
    local status expiry expires_at remaining condition payload headline message
    status=$(ts status --json) || true
    expiry=$(printf '%s' "$status" | jq -er '.Self.KeyExpiry // ""' 2>/dev/null) || return 0
    if [ -z "$expiry" ]; then
        [ "$(printf '%s' "$status" | jq -r '.BackendState')" = Running ] || return 0
        condition=clear
    else
        expires_at=$(date -u -d "$expiry" +%s 2>/dev/null) || return 0
        remaining=$((expires_at - $(date +%s)))
        if [ "$remaining" -le 0 ]; then
            condition="expired:$expiry"
            headline='La clave del nodo de Tailscale ha caducado / Tailscale node key expired'
        elif [ "$remaining" -le "$((expiry_notice_days * 86400))" ]; then
            condition="soon:$expiry"
            headline='La clave del nodo de Tailscale caduca pronto / Tailscale node key expires soon'
        else
            condition=clear
        fi
    fi

    [ "$condition" != "$expiry_notice_state" ] || return 0
    if [ "$condition" = clear ]; then
        payload=$(jq -nc --arg id "$expiry_notice_id" '{notification_id: $id}')
        if [ -z "${SUPERVISOR_TOKEN:-}" ] || expiry_notification dismiss "$payload"; then
            expiry_notice_state=$condition
        fi
        return 0
    fi

    message="$(printf '%s\n\n%s\n\n%s\n\n%s' \
        "$headline" \
        "Fecha / Date: $expiry" \
        '[Abrir Tailscale Machines / Open Tailscale Machines](https://console.tailscale.com/admin/machines)' \
        '[Instrucciones de renovación / Reauthentication instructions](https://tailscale.com/docs/features/access-control/key-expiry)')"
    echo "BYD MQTT: $headline ($expiry). https://console.tailscale.com/admin/machines"
    payload=$(jq -nc --arg id "$expiry_notice_id" --arg message "$message" \
        '{notification_id: $id, title: "BYD MQTT", message: $message}')
    if [ -z "${SUPERVISOR_TOKEN:-}" ] || expiry_notification create "$payload"; then
        expiry_notice_state=$condition
    fi
}
