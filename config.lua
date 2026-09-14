Config = {}

-- ─────────────────────────────────────────
--  ZELTRADE — API
-- ─────────────────────────────────────────
Config.ApiKey = ''  -- COLOCA AQUI TU APIKEY (se genera en tu dashboard de ZelTrade, seccion FiveM)
Config.ApiUrl = 'https://zeltrade.shop/fivem/api'

-- ─────────────────────────────────────────
--  FRAMEWORK
--  'esx' | 'qbcore' | 'qbox'
-- ─────────────────────────────────────────
Config.Framework = 'esx'  -- CAMBIA SEGUN TU FRAMEWORK

-- ─────────────────────────────────────────
--  SERVIDOR — info para la UI
-- ─────────────────────────────────────────
Config.ServerName   = ''  -- COLOCA AQUI EL NOMBRE DE TU SERVIDOR
Config.ServerBanner = ''  -- COLOCA AQUI LA URL DE LA IMAGEN DEL BANNER (opcional, deja vacio si no quieres banner)

-- ─────────────────────────────────────────
--  MONEDA
--  Nombre de la cuenta/item que se le suma al jugador al canjear.
--  Ejemplos segun tu configuracion:
--  Config.CurrencyAccount = 'coin'    -- cuenta addon de ESX (esx_addonaccount)
--  Config.CurrencyAccount = 'bank'    -- dinero de banco en QBCore/Qbox
--  Config.CurrencyAccount = 'crypto'  -- item o moneda personalizada
-- ─────────────────────────────────────────
Config.CurrencyAccount = 'coin'  -- CAMBIA SEGUN EL NOMBRE DE TU MONEDA

-- ─────────────────────────────────────────
--  NPC
-- ─────────────────────────────────────────
Config.Ped = {
    model  = 'a_m_m_business_01',
    coords = vector4(-1289.5566, -576.8382, 30.5732, 331.9847), -- CAMBIA POR LAS COORDENADAS REALES DE TU SERVIDOR
    label  = 'ZelTrade · Canjear código',
}

-- ─────────────────────────────────────────
--  NOTIFICACIONES
--  Se elige sola segun Config.Framework de arriba, no hay que tocar nada aqui.
-- ─────────────────────────────────────────
Config.ServerNotify = function(source, text, type)
    TriggerClientEvent('zeltradecode:notify', source, text, type or 'info')
end

Config.ClientNotify = function(text, type)
    type = type or 'info'

    if Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.ShowNotification(text)
    elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(text, type, 5000)
    end
end

-- ─────────────────────────────────────────
--  TEXT UI
--  Igual que las notificaciones, se elige sola segun Config.Framework.
-- ─────────────────────────────────────────
Config.TextUI = {
    Open = function(msg)
        if Config.Framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.TextUI('[E] ' .. msg)
        elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            exports['qb-core']:DrawText('[E] ' .. msg, 'left')
        end
    end,
    Close = function()
        if Config.Framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.HideUI()
        elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            exports['qb-core']:HideText()
        end
    end,
}



