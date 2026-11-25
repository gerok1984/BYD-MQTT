"""Relay one topic between Mosquitto and EMQX without echoing messages."""

import json
import os
import re
import signal
import threading
import urllib.request

from paho.mqtt import client as mqtt
from paho.mqtt.subscribeoptions import SubscribeOptions


def get_local_broker():
    request = urllib.request.Request(
        "http://supervisor/services/mqtt",
        headers={"Authorization": "Bearer " + os.environ["SUPERVISOR_TOKEN"]},
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.load(response)["data"]


def configure_relay(source, destination, topic, label, *, from_cloud=False):
    source.ready = threading.Event()

    def on_connect(client, userdata, flags, reason, properties):
        if reason != 0:
            print(f"BYD MQTT: {label}: {reason}.", flush=True)
            return
        client.subscribe(
            topic,
            options=SubscribeOptions(
                qos=0, noLocal=True, retainAsPublished=True,
                retainHandling=0 if from_cloud else 2,
            ),
        )

    def on_subscribe(client, userdata, mid, reasons, properties):
        if reasons and reasons[0].value < 128:
            client.ready.set()
            print(f"BYD MQTT: {label}: {topic}", flush=True)
        else:
            print(f"BYD MQTT: {label}: {reasons}.", flush=True)

    def on_disconnect(client, userdata, reason, properties=None):
        client.ready.clear()
        if reason != 0:
            print(f"BYD MQTT: {label}: {reason}.", flush=True)

    def on_message(client, userdata, message):
        # Never relay retained commands or queue commands for a disconnected peer.
        if (not from_cloud and message.retain) or not destination.ready.is_set():
            return
        destination.publish(
            message.topic, message.payload, qos=0, retain=from_cloud and message.retain
        )

    source.on_connect = on_connect
    source.on_subscribe = on_subscribe
    source.on_disconnect = on_disconnect
    source.on_message = on_message
    source.reconnect_delay_set(min_delay=2, max_delay=60)


def main():
    with open("/data/options.json", encoding="utf-8") as options_file:
        options = json.load(options_file)
    host = options.get("emqx_host", "").strip()
    topic = options.get("electro_topic", "").strip()
    username = options.get("emqx_username")
    password = options.get("emqx_password")
    if not re.fullmatch(r"[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+", host):
        raise SystemExit("BYD MQTT: emqx_host debe contener solo el nombre DNS de EMQX.")
    if not topic or any(character in topic for character in "+#\0") or len(topic.encode()) > 65535:
        raise SystemExit("BYD MQTT: electro_topic debe ser un tópico MQTT exacto, sin comodines.")
    if not username or not password:
        raise SystemExit("BYD MQTT: configura emqx_username y emqx_password.")

    try:
        broker = get_local_broker()
        local_host, local_port = broker["host"], broker["port"]
    except (KeyError, ValueError, OSError):
        raise SystemExit("BYD MQTT: no se pudo obtener el servicio MQTT de Home Assistant.") from None

    local = mqtt.Client(protocol=mqtt.MQTTv5)
    cloud = mqtt.Client(protocol=mqtt.MQTTv5)
    if broker.get("username"):
        local.username_pw_set(broker["username"], broker.get("password"))
    if broker.get("ssl"):
        local.tls_set()
    cloud.username_pw_set(username, password)
    cloud.tls_set()

    configure_relay(local, cloud, topic, "Mosquitto → EMQX")
    configure_relay(cloud, local, topic, "EMQX → Mosquitto", from_cloud=True)

    stop = threading.Event()
    signal.signal(signal.SIGTERM, lambda *_: stop.set())
    signal.signal(signal.SIGINT, lambda *_: stop.set())
    local.connect_async(local_host, local_port, clean_start=True)
    cloud.connect_async(host, 8883, clean_start=True)
    local.loop_start()
    cloud.loop_start()
    try:
        stop.wait()
    finally:
        for client in (local, cloud):
            client.disconnect()
            client.loop_stop()


if __name__ == "__main__":
    main()
