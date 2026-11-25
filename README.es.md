# BYD MQTT

[English](README.md) · [Português (Brasil)](README.pt-BR.md)

BYD MQTT es un complemento para Home Assistant OS que da a un cliente MQTT remoto una URL WebSocket segura para acceder al broker oficial Mosquitto. Se creó para usar Electro en un BYD Dolphin pero admite cualquier cliente compatible con MQTT sobre WebSocket. Usa Tailscale Funnel para reenviar el tráfico a `core-mosquitto:1884`. Puedes seguir usando Nabu Casa para acceder a Home Assistant. No hace falta abrir puertos en el router.

También puedes elegir **EMQX Cloud (beta)** para recibir telemetría y enviar comandos por un mismo tópico. Tailscale avisa de las caídas del túnel con una notificación persistente de Home Assistant.

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
