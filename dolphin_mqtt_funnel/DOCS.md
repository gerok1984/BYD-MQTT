# BYD MQTT 1.0

[Español](DOCS.es.md)

## Configure

1. Start the official **Mosquitto broker** add-on. Set up a dedicated MQTT username and strong password, with ACLs limited to the relevant topics. The public WebSocket endpoint passes MQTT credentials to Mosquitto, which applies its regular access controls.
2. Open the [Tailscale DNS settings](https://console.tailscale.com/admin/dns) and enable MagicDNS and HTTPS certificates. In [Access controls](https://console.tailscale.com/admin/acls), [authorize Funnel](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) for the registration identity.
3. Generate a [single-use, non-ephemeral auth key](https://console.tailscale.com/admin/settings/keys). Paste it into `tailscale_auth_key` on the **BYD MQTT** configuration page. Enable `publish`, save, and start the add-on.
4. Open the add-on log and copy the `wss://…ts.net/mqtt` URL. Once registration succeeds, you can clear `tailscale_auth_key` from the configuration. The node identity is stored in the add-on's persistent data.

## Test and switch clients

1. From an external network, connect with a WebSocket-capable MQTT client using the complete URL, port **443**, path **/mqtt**, and the Mosquitto credentials. For a mobile test, turn off Wi-Fi and disconnect the Tailscale client on the phone.
2. Confirm that an invalid password is rejected. With the authorized account, subscribe to a permitted test topic and publish a message to the same topic.
3. Save your existing broker settings before changing the Dolphin. Switch to the new URL, confirm that fresh telemetry arrives in Home Assistant, and repeat the test using the car's mobile data.

## Upgrade a local installation

Stop the add-on. Replace the files in `/addons/dolphin_mqtt_funnel/` with those from this release, reload the store, and select **Update** on the installed add-on. Start it again. Updating the existing installation preserves the stored Tailscale node identity. Use the same path from previous releases to retain the existing instance.

## Troubleshooting

- **Funnel/TLS error:** Check MagicDNS, HTTPS certificates, and the Funnel policy. Public DNS may take a few minutes to propagate.
- **HTTP 502:** Confirm Mosquitto is running and its internal WebSocket listener is available on port 1884.
- **MQTT authentication error:** Check the Mosquitto username and password. If connection succeeds but messages fail, check the topic ACLs.
- **Disable external access:** Stop the add-on and set `publish: false`. The public endpoint requires the add-on to be running.
