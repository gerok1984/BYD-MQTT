# BYD MQTT

[English](README.md) · [Português (Brasil)](README.pt-BR.md)

BYD MQTT es un complemento para Home Assistant OS que da a un cliente MQTT remoto una URL WebSocket segura para acceder al broker oficial Mosquitto. Se creó para usar Electro en un BYD Dolphin pero admite cualquier cliente compatible con MQTT sobre WebSocket. Usa Tailscale Funnel para reenviar el tráfico a `core-mosquitto:1884`. Puedes seguir usando Nabu Casa para acceder a Home Assistant. No hace falta abrir puertos en el router.

También puedes elegir **EMQX Cloud (beta)** para recibir telemetría y enviar comandos por un mismo tópico. Tailscale avisa de las caídas del túnel con una notificación persistente de Home Assistant.

## Modos de conexión

Elige **Tailscale**, **EMQX Cloud (beta)** o **Ambos (beta)** en los ajustes del complemento. Para usar Ambos, deja `publish: true` y reinicia el complemento. En Electro y en el campo **Tópico de Electro** del complemento, usa el tópico original, por ejemplo `electro/telemetry/dolphin/data`.

En modo Ambos, publica las órdenes desde Home Assistant en el tópico original para Tailscale o en `electro/telemetry/dolphin/data/emqx_command` para EMQX. Usa el sufijo solo en la acción `mqtt.publish` de Home Assistant. [Guía de configuración](byd_mqtt/DOCS.es.md#ambos-modos-beta)

## Requisitos

- Home Assistant OS en amd64 o aarch64 y el complemento oficial **Mosquitto broker** iniciado.
- En modo Tailscale, usa una cuenta de [Tailscale](https://tailscale.com/) con [MagicDNS y certificados HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates) activados y [Funnel permitido](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para la identidad que registre el complemento.
- En modo Tailscale, usa un cliente compatible con MQTT sobre WebSockets seguros (WSS) y una cuenta autenticada de Mosquitto.

## Instalación

1. En **Ajustes → Aplicaciones (o Complementos) → Tienda → ⋮ → Repositorios**, añade `https://github.com/gerok1984/BYD-MQTT`.
2. Busca **BYD MQTT** en la tienda e instálalo.
3. Sigue la [guía de configuración y prueba](byd_mqtt/DOCS.es.md).

Para instalarlo de forma local, copia la carpeta `byd_mqtt` a `/addons/` y recarga la tienda.

Funnel da al servicio MQTT una URL pública. Mosquitto autentica la conexión y aplica los permisos existentes. Mantén desactivado el acceso anónimo y utiliza una cuenta dedicada con permisos limitados a los topics que necesita el cliente.

## Configuración MQTT de Electro

El complemento se creó para la app [Electro](https://www.electro.app.br/). [Configuración MQTT de Electro](byd_mqtt/DOCS.es.md#configurar-mqtt-en-electro).
