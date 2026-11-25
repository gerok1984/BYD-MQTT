# BYD MQTT

[English](README.md) · [Español](README.es.md)

BYD MQTT é um complemento para o Home Assistant OS que fornece a um cliente MQTT remoto uma URL WebSocket segura para acessar o broker oficial Mosquitto. Foi desenvolvido para usar o Electro em um BYD Dolphin, mas aceita qualquer cliente compatível com MQTT via WebSocket. O Tailscale Funnel encaminha o tráfego para `core-mosquitto:1884`. Você pode continuar usando o Nabu Casa para acessar o Home Assistant. Não é necessário abrir portas no roteador.

## Requisitos

- Home Assistant OS em amd64 ou aarch64 e o complemento oficial **Mosquitto broker** em execução.
- Uma conta no [Tailscale](https://tailscale.com/) com [MagicDNS e certificados HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates) ativados e [permissão para usar o Funnel](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para a identidade que vai registrar o complemento.
- Um cliente compatível com MQTT via WebSocket seguro (WSS) e uma conta MQTT no Mosquitto.

## Instalação

1. No Home Assistant, abra **Configurações → Aplicativos (ou Complementos) → Loja → ⋮ → Repositórios** e adicione `https://github.com/gerok1984/BYD-MQTT`.
2. Na loja, procure **BYD MQTT** e instale o complemento.
3. Siga o [guia de configuração e teste](byd_mqtt/DOCS.pt-BR.md).

Para uma instalação local, copie a pasta `byd_mqtt` para `/addons/` e recarregue a loja.

O Funnel fornece uma URL pública para o serviço MQTT. O Mosquitto autentica a conexão e aplica as permissões existentes. Mantenha o acesso anônimo desativado e use uma conta dedicada com acesso restrito aos tópicos necessários.

## MQTT no Electro

O complemento foi desenvolvido para o aplicativo [Electro](https://www.electro.app.br/). Veja [como configurar o MQTT no Electro](byd_mqtt/DOCS.pt-BR.md#configurar-o-mqtt-no-electro).
