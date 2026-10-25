Locales = Locales or {}

Locales.es = {
    target = 'Canjear código ZelTrade',
    key_prompt = '[E] Canjear código ZelTrade',
    blip = 'ZelTrade · Canjear código',

    reward_coins = 'JVLCoins',
    reward_account = 'de dinero',
    reward_item = 'artículos',

    ok_redeemed = '¡Código canjeado! Recibiste %s %s',
    ok_pending = 'Te entregamos un canje pendiente: %s %s',
    err_invalid = 'Código inválido',
    err_far = 'Acércate al encargado de ZelTrade',
    err_wait = 'Espera %s segundos para intentar de nuevo',
    err_locked = 'Demasiados códigos incorrectos. Intenta en %s minutos',
    err_rejected = 'El código no es válido o ya fue usado',
    err_api = 'ZelTrade no responde. Intenta más tarde',
    err_unavailable = 'El canje no está disponible ahora',
    err_pending = 'Código aceptado. Tu recompensa se entregará al volver a entrar',

    -- NUI
    ui_title = 'Canjear código',
    ui_desc = 'Ingresa el código de tu compra en la tienda para recibir tu recompensa.',
    ui_placeholder = 'ZELT-XXXX-XXXX',
    ui_redeem = 'Canjear',
    ui_redeeming = 'Canjeando...',
    ui_close = 'Cerrar',
    ui_hint = 'ESC para cerrar',
}
