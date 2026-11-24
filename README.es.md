# BYD MQTT

[English](README.md)

BYD MQTT es un complemento para Home Assistant OS que da a un cliente MQTT remoto una URL WebSocket segura para acceder al broker oficial Mosquitto. Se creó para el BYD Dolphin y admite clientes compatibles con MQTT sobre WebSocket. Usa Tailscale Funnel para reenviar el tráfico a `core-mosquitto:1884`. Puedes seguir usando Nabu Casa para acceder a Home Assistant. No hace falta abrir puertos en el router.

## Requisitos

- Home Assistant OS en amd64 o aarch64 y el complemento oficial **Mosquitto broker** iniciado.
- Una cuenta de [Tailscale](https://tailscale.com/) con [MagicDNS y certificados HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates) activados y [Funnel permitido](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para la identidad que registre el complemento.
- Un cliente compatible con MQTT sobre WebSockets seguros (WSS) y una cuenta autenticada de Mosquitto.

## Instalación

1. En **Ajustes → Aplicaciones (o Complementos) → Tienda → ⋮ → Repositorios**, añade `https://github.com/gerok1984/BYD-MQTT`.
2. Busca **BYD MQTT** en la tienda e instálalo.
3. Sigue la [guía de configuración y prueba](dolphin_mqtt_funnel/DOCS.es.md).

Para instalarlo de forma local, copia la carpeta `dolphin_mqtt_funnel` a `/addons/` y recarga la tienda. Si ya lo instalaste localmente, sigue los [pasos de actualización](dolphin_mqtt_funnel/DOCS.es.md#actualizar-una-instalación-local) sobre la misma instalación para conservar el nodo de Tailscale y su URL.

Funnel da al servicio MQTT una URL pública. Mosquitto autentica la conexión y aplica los permisos existentes. Mantén desactivado el acceso anónimo y utiliza una cuenta dedicada con permisos limitados a los topics que necesita el cliente.
