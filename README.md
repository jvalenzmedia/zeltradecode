# zeltradecode

Recurso de FiveM para canjear códigos de compra de **ZelTrade** (zeltrade.shop). El jugador interactúa con un NPC en el servidor, ingresa el código que recibió al comprar en la tienda, y recibe la moneda configurada directamente en su cuenta.

## Requisitos

- [ox_target](https://github.com/overextended/ox_target)
- Framework: ESX, QBCore o Qbox
- Una Apikey generada desde el dashboard de vendedor en ZelTrade (sección FiveM)

## Instalación

1. Coloca la carpeta `zeltradecode` en tu carpeta `resources`.
2. Abre `config.lua` y configura:
   - `Config.ApiKey` — tu Apikey real de ZelTrade.
   - `Config.Framework` — `'esx'`, `'qbcore'` o `'qbox'`.
   - `Config.ServerName`, `Config.ServerBanner` — datos de tu servidor.
   - `Config.CurrencyAccount` — el nombre de la cuenta/moneda que se le entrega al jugador.
   - `Config.Ped.coords` — dónde aparece el NPC de canje en tu mapa.
3. Agrega `ensure zeltradecode` a tu `server.cfg`.

## Cómo funciona

- Al iniciar, el recurso verifica tu Apikey contra la API de ZelTrade (`verify-license.php`).
- El jugador interactúa con el NPC (ox_target), ingresa su código, y el servidor lo valida contra ZelTrade (`redeem-code.php`).
- Si el código es válido, se le entrega la moneda configurada al jugador en el framework correspondiente.

## Licencia

Software propietario — ver [LICENSE](LICENSE). No redistribuir ni revender sin autorización de JVL MediaCode.

---

Desarrollado por [JVL MediaCode](https://www.jvlmediacode.com)
