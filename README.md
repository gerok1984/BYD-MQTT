# BYD MQTT

[Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)

BYD MQTT is a Home Assistant OS add-on that gives a remote MQTT client a secure WebSocket URL for the official Mosquitto broker. It was built to use Electro in a BYD Dolphin but supports any client compatible with MQTT over WebSocket. It forwards MQTT traffic to `core-mosquitto:1884` through Tailscale Funnel. It requires no router port forwarding. You can keep using Nabu Casa to access Home Assistant.

You can also choose **EMQX Cloud (beta)** for bidirectional telemetry and commands on a single topic. Tailscale reports tunnel outages through a persistent Home Assistant notification.

## Connection modes

Choose **Tailscale**, **EMQX Cloud (beta)**, or **Both (beta)** in the add-on settings. For Both, keep `publish: true` and restart the add-on. In Electro and in the add-on's Electro topic field, use the original topic, such as `electro/telemetry/dolphin/data`.

In Both mode, publish commands from Home Assistant to the original topic for Tailscale or to `electro/telemetry/dolphin/data/emqx_command` for EMQX. Use the suffix only in the Home Assistant `mqtt.publish` action. [Setup guide](byd_mqtt/DOCS.md#both-modes-beta)

## Requirements

- Home Assistant OS on amd64 or aarch64 and the official **Mosquitto broker** add-on running.
- In Tailscale mode, use a [Tailscale](https://tailscale.com/) account with [MagicDNS and HTTPS certificates](https://tailscale.com/docs/how-to/set-up-https-certificates) enabled and [Funnel permitted](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) for the identity registering the add-on.
- In Tailscale mode, use a client that supports MQTT over secure WebSockets (WSS) and an authenticated Mosquitto account.

## Install

1. Open **Settings → Apps (or Add-ons) → App store → ⋮ → Repositories**. Add `https://github.com/gerok1984/BYD-MQTT`.
2. Find **BYD MQTT** in the store and install it.
3. Follow the [configuration and testing guide](byd_mqtt/DOCS.md).

For a local installation, copy the `byd_mqtt` folder to `/addons/` and reload the store.

Funnel gives the MQTT endpoint a public URL. Mosquitto authenticates the connection and applies its existing permissions. Keep anonymous access disabled and use a dedicated account limited to the MQTT topics the client needs.

## Electro MQTT setup

The add-on was built for the [Electro](https://www.electro.app.br/) app. [Electro MQTT setup](byd_mqtt/DOCS.md#configure-mqtt-in-electro).
