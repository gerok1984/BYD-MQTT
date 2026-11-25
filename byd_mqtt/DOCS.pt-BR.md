# BYD MQTT 1.2.0

[English](https://github.com/gerok1984/BYD-MQTT/blob/main/byd_mqtt/DOCS.md) · [Español](https://github.com/gerok1984/BYD-MQTT/blob/main/byd_mqtt/DOCS.es.md) · [GitHub](https://github.com/gerok1984/BYD-MQTT)

## Configurar o Tailscale Funnel

O Tailscale continua sendo o modo padrão. Mantenha `mode: tailscale` e ative `publish` para usá-lo.

1. Inicie o complemento oficial **Mosquitto broker**. Crie um usuário MQTT dedicado com uma senha forte e restrinja suas permissões (ACLs) aos tópicos necessários. O Mosquitto valida as credenciais enviadas pela conexão WebSocket.
2. Nas [configurações de DNS do Tailscale](https://console.tailscale.com/admin/dns), ative o MagicDNS e os certificados HTTPS. Em [Access controls](https://console.tailscale.com/admin/acls), [autorize o Funnel](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para a identidade que vai registrar o complemento.
3. Em [Tailscale → Keys](https://console.tailscale.com/admin/settings/keys), clique em **Generate auth key**. Deixe **Reusable** e **Ephemeral** desativados. Cole a chave em `tailscale_auth_key` nas configurações do **BYD MQTT**, ative `publish`, salve e inicie o complemento.
4. Abra o log do complemento e copie a URL `wss://…ts.net/mqtt`. Após registrar o nó, você pode apagar o valor de `tailscale_auth_key`. A identidade do nó fica salva nos dados persistentes do complemento.

Se você desinstalou o complemento ou mudou de uma instalação local para a do repositório, registre a nova instalação com uma nova chave. Confira a URL WSS no log e atualize o Electro caso ela tenha mudado.

## EMQX Cloud (beta)

Para trocar de modo, salve o novo `mode`, reinicie o BYD MQTT e configure o Electro com o broker escolhido. Você pode manter as configurações dos dois modos e deixar `publish` ativado ao usar o EMQX. Essa opção só se aplica ao Tailscale. Ao iniciar no modo Tailscale, o complemento publica o Funnel novamente com a identidade salva do nó.

Selecione `mode: emqx` para receber telemetria e enviar comandos pelo mesmo tópico. O Electro e o complemento iniciam conexões de saída com o EMQX. O Home Assistant continua usando o Mosquitto local.

1. Crie uma [implantação Serverless no EMQX Cloud](https://docs.emqx.com/en/cloud/latest/create/serverless.html). Crie credenciais separadas para o Electro e para o complemento, com permissão para publicar e assinar o tópico exato.
2. Nome do servidor EMQX, sem protocolo, porta ou caminho → `emqx_host`.
3. Credenciais do EMQX para a ponte → `emqx_username` / `emqx_password`.
4. Tópico exato exibido em **Editar publicação → Tópico** no Electro, por exemplo `electro/telemetry/dolphin/data` → `electro_topic`.
5. Inicie o complemento. No Electro, configure o servidor EMQX, a porta **8883**, **Usar SSL** ativado e as credenciais do Electro. Mantenha o nome do dispositivo para preservar o tópico.

Confira no registro as assinaturas nas duas direções. Com o Wi-Fi do carro desligado, confirme a chegada de novos dados no Home Assistant e envie um comando que você já usa. Confirme que o Electro o executa. Publique os comandos com a retenção desativada. Use uma ponte por tópico.

## Ambos os modos (beta)

Selecione `mode: both`, mantenha `publish: true` e reinicie o complemento. Configure cada publicação MQTT do Electro com seu broker e suas credenciais. Ambas podem usar o mesmo tópico do Electro. O Home Assistant recebe a telemetria nesse tópico e recebe as duas publicações se o Electro enviar a mesma atualização duas vezes.

Para cada comando do Home Assistant, escolha um tópico MQTT. Use o tópico original para enviá-lo pelo Tailscale ou acrescente `/emqx_command` ao final para enviá-lo pelo EMQX. Por exemplo, publique em `electro/telemetry/dolphin/data/emqx_command`. A ponte envia o comando ao EMQX em `electro/telemetry/dolphin/data`. Mantenha a retenção desativada. Nesse modo, as automações existentes continuam enviando comandos pelo Tailscale.

## Aviso de falha do túnel Tailscale

O complemento verifica o endpoint MQTT público por WebSocket a cada 30 segundos. Após três falhas consecutivas, cria uma notificação persistente em **Notificações** no Home Assistant. Se a inicialização falhar ou um processo parar, o aviso é imediato quando o Home Assistant está acessível. O aviso é removido quando o endpoint volta a responder. A verificação cobre o túnel até o Mosquitto e funciona mesmo se o carro estiver desconectado.

## Expiração das chaves do Tailscale

- **Chave de registro.** Uma chave de uso único é revogada pelo Tailscale assim que registra um nó.
- **Chave do nó.** O dispositivo registrado tem sua própria chave, que expira em 180 dias por padrão. Consulte a data do seu nó em [Tailscale → Machines](https://console.tailscale.com/admin/machines).
- **Aviso.** Enquanto estiver em execução, o complemento verifica a data de expiração informada pelo Tailscale aproximadamente a cada hora. Quando faltarem 14 dias ou menos, ele escreve um aviso no log e cria uma notificação persistente no Home Assistant com links para a página Machines e para as [instruções de reautenticação](https://tailscale.com/docs/features/access-control/key-expiry).

## Configurar o MQTT no Electro

No [Electro](https://www.electro.app.br/), crie ou edite uma publicação MQTT, preencha os campos e salve.

| Campo | Valor |
| --- | --- |
| Nome | Um nome à sua escolha, por exemplo `Home Assistant` |
| Host do broker | A URL completa exibida no log, por exemplo `wss://seu-no.sua-tailnet.ts.net/mqtt` |
| Porta | `443` |
| Usar SSL | Desativado, conforme a configuração testada no Electro. O prefixo `wss://` ativa TLS para a conexão WebSocket. |
| Usuário e senha | As credenciais MQTT do Mosquitto |
| Nome do dispositivo | Mantenha o nome atual para preservar o tópico, por exemplo `Dolphin`. |
| Tópico | Gerado pelo Electro. Para `Dolphin`, um exemplo é `electro/telemetry/dolphin/data`. |

Na integração MQTT do Home Assistant, escute o tópico exibido pelo Electro e confira se chega uma mensagem nova. Se você usa o HiveMQ, guarde a configuração anterior até confirmar a conexão pelos dados móveis do carro.

## Teste e troca de servidor

1. Em uma rede externa, conecte um cliente MQTT compatível com WebSocket usando a URL completa, a porta **443**, o caminho **/mqtt** e as credenciais do Mosquitto. Para testar pelo celular, desligue o Wi-Fi e desconecte o Tailscale no aparelho.
2. Confira se uma senha incorreta é rejeitada. Com a conta autorizada, inscreva-se em um tópico de teste permitido e publique uma mensagem nesse mesmo tópico.
3. Guarde as configurações do broker anterior antes de alterar o Dolphin. Use a nova URL, confirme que chegam novos dados ao Home Assistant e repita o teste usando a conexão móvel do carro.

## Solução de problemas

- **Erro de Funnel ou TLS.** Confira o MagicDNS, os certificados HTTPS e a política do Funnel. O DNS público pode levar alguns minutos para propagar.
- **HTTP 502.** Confira se o Mosquitto está em execução e se o listener WebSocket interno está disponível na porta 1884.
- **Erro de autenticação MQTT.** Confira o usuário e a senha do Mosquitto. Se a conexão funcionar e as mensagens falharem, verifique as permissões do tópico.
- **Desativar o acesso externo.** Pare o complemento e salve `publish: false`. O acesso público depende de o complemento estar em execução.
