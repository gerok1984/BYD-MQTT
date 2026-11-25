# BYD MQTT

[English](README.md) · [Español](README.es.md)

BYD MQTT é um complemento para o Home Assistant OS que fornece a um cliente MQTT remoto uma URL WebSocket segura para acessar o broker oficial Mosquitto. Foi desenvolvido para usar o Electro em um BYD Dolphin, mas aceita qualquer cliente compatível com MQTT via WebSocket. O Tailscale Funnel encaminha o tráfego para `core-mosquitto:1884`. Você pode continuar usando o Nabu Casa para acessar o Home Assistant. Não é necessário abrir portas no roteador.

Você também pode escolher o **EMQX Cloud (beta)** para receber telemetria e enviar comandos pelo mesmo tópico. O Tailscale avisa sobre falhas no túnel com uma notificação persistente no Home Assistant.

## Modos de conexão

Escolha **Tailscale**, **EMQX Cloud (beta)** ou **Ambos (beta)** nas configurações do complemento. Para usar Ambos, mantenha `publish: true` e reinicie o complemento. No Electro e no campo **Tópico do Electro** do complemento, use o tópico original, por exemplo `electro/telemetry/dolphin/data`.

No modo Ambos, publique os comandos do Home Assistant no tópico original para usar o Tailscale ou em `electro/telemetry/dolphin/data/emqx_command` para usar o EMQX. Use o sufixo apenas na ação `mqtt.publish` do Home Assistant. [Guia de configuração](byd_mqtt/DOCS.pt-BR.md#ambos-os-modos-beta)

## Requisitos

- Home Assistant OS em amd64 ou aarch64 e o complemento oficial **Mosquitto broker** em execução.
- No modo Tailscale, use uma conta do [Tailscale](https://tailscale.com/) com [MagicDNS e certificados HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates) ativados e [permissão para usar o Funnel](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para a identidade que vai registrar o complemento.
- No modo Tailscale, use um cliente compatível com MQTT via WebSocket seguro (WSS) e uma conta MQTT no Mosquitto.

## Instalação

1. No Home Assistant, abra **Configurações → Aplicativos (ou Complementos) → Loja → ⋮ → Repositórios** e adicione `https://github.com/gerok1984/BYD-MQTT`.
2. Na loja, procure **BYD MQTT** e instale o complemento.
3. Siga o [guia de configuração e teste](byd_mqtt/DOCS.pt-BR.md).

Para uma instalação local, copie a pasta `byd_mqtt` para `/addons/` e recarregue a loja.

O Funnel fornece uma URL pública para o serviço MQTT. O Mosquitto autentica a conexão e aplica as permissões existentes. Mantenha o acesso anônimo desativado e use uma conta dedicada com acesso restrito aos tópicos necessários.

## MQTT no Electro

O complemento foi desenvolvido para o aplicativo [Electro](https://www.electro.app.br/). Veja [como configurar o MQTT no Electro](byd_mqtt/DOCS.pt-BR.md#configurar-o-mqtt-no-electro).
