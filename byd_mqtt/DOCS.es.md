# BYD MQTT 1.0.4

[English](DOCS.md) · [Português (Brasil)](DOCS.pt-BR.md)

## Configuración

1. Inicia el complemento oficial **Mosquitto broker**. Configura un usuario MQTT dedicado con contraseña fuerte y limita sus permisos (ACL) a los topics que necesite. La URL pública WebSocket pasa las credenciales a Mosquitto, que aplica sus reglas de acceso.
2. En la [configuración DNS de Tailscale](https://console.tailscale.com/admin/dns), activa MagicDNS y los certificados HTTPS. Desde [Access controls](https://console.tailscale.com/admin/acls), [autoriza Funnel](https://tailscale.com/docs/features/tailscale-funnel#funnel-node-attribute) para la identidad que registre el complemento.
3. Genera una [clave de registro](https://console.tailscale.com/admin/settings/keys) de un solo uso y para un nodo persistente. Deja **Reusable** y **Ephemeral** desactivados. Pega la clave en `tailscale_auth_key` en la configuración de **BYD MQTT**. Activa `publish`, guarda e inicia el complemento.
4. Abre el registro y copia la dirección `wss://…ts.net/mqtt`. Una vez registrado el nodo, puedes vaciar `tailscale_auth_key`. La identidad se guarda en los datos persistentes del complemento.

Si desinstalaste el complemento o cambiaste de una instalación local a la del repositorio, registra la nueva instalación con una clave nueva. La clave de un solo uso queda revocada tras usarla. Copia la URL WSS del nuevo registro y actualiza Electro si ha cambiado.

## Caducidad de las claves de Tailscale

- **Clave de registro:** En [Tailscale → Keys](https://console.tailscale.com/admin/settings/keys), pulsa **Generate auth key** y deja **Reusable** y **Ephemeral** desactivados. Tailscale revoca una clave de un solo uso en cuanto registra un nodo. Después puedes vaciar ese campo en el complemento.
- **Clave del nodo:** El dispositivo registrado tiene su propia clave, que caduca a los 180 días por defecto. Consulta el ajuste y la fecha reales de tu nodo en [Tailscale → Machines](https://console.tailscale.com/admin/machines).
- **Aviso:** Mientras el complemento está en marcha, comprueba la fecha que informa Tailscale aproximadamente cada hora. Cuando quedan 14 días o menos, escribe un aviso en el registro y crea una notificación persistente en Home Assistant con enlaces a Machines y a las [instrucciones de renovación](https://tailscale.com/docs/features/access-control/key-expiry).

## Configurar MQTT en Electro

En [Electro](https://www.electro.app.br/), crea o edita una publicación MQTT. Rellena estos campos y guarda la publicación.

| Campo | Valor |
| --- | --- |
| Nombre | Una etiqueta, por ejemplo `Home Assistant` |
| Host del broker | La URL completa del registro del complemento, por ejemplo `wss://tu-nodo.tu-tailnet.ts.net/mqtt` |
| Puerto | `443` |
| Usar SSL | Desactivado, como en la configuración probada de Electro. El prefijo `wss://` activa TLS para la conexión WebSocket. |
| Usuario y contraseña | Las credenciales MQTT de Mosquitto |
| Nombre del dispositivo | Conserva el nombre que ya usas para mantener el tópico. Por ejemplo, `Dolphin`. |
| Tópico | Electro lo genera. Con `Dolphin`, el ejemplo es `electro/telemetry/dolphin/data`. |

Escucha el tópico que muestra Electro desde la integración MQTT de Home Assistant y comprueba que llegue un mensaje nuevo. Si vienes de HiveMQ, guarda la configuración anterior hasta comprobar la conexión con los datos móviles del coche.

## Prueba y cambio de servidor

1. Desde una red externa, usa un cliente MQTT compatible con WebSocket. Introduce la URL completa, el puerto **443**, la ruta **/mqtt** y las credenciales de Mosquitto. Para probar desde el móvil, desactiva el Wi-Fi y desconecta Tailscale en el teléfono.
2. Comprueba que se rechaza una contraseña incorrecta. Con el usuario autorizado, suscríbete a un topic de prueba permitido y publica un mensaje en el mismo topic.
3. Guarda la configuración del broker anterior antes de cambiar el Dolphin. Introduce la nueva dirección, comprueba que llega telemetría nueva a Home Assistant y repite la prueba con los datos móviles del coche.


## Solución de problemas

- **Error de Funnel o TLS.** Comprueba MagicDNS, los certificados HTTPS y la política de Funnel. El DNS público puede tardar unos minutos en propagarse.
- **HTTP 502.** Comprueba que Mosquitto está en marcha y que su listener WebSocket interno está disponible en el puerto 1884.
- **Error de autenticación MQTT.** Comprueba el usuario y la contraseña de Mosquitto. Si conecta pero fallan los mensajes, revisa los permisos del topic.
- **Cerrar el acceso externo.** Detén el complemento y guarda `publish: false`. El acceso público requiere que el complemento esté en ejecución.
