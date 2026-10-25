--[[
    ZelTrade Code | Configuration
    NPC where players redeem the purchase codes of your ZelTrade store. The SERVER sends the code to the
    ZelTrade API and gives the player the amount the API returns (as JVLCoins, a money account or an item).

    Multiframework: Qbox, QBCore and ESX (auto-detected). Target: ox_target, qb-target or the [E] key.
    No tables, no items (unless Config.Reward.type = 'item'). No fxmanifest dependencies.

    Convars (server only: use "set", never "setr" / "sets"; this file is sent to the players):
        set zeltrade_api_key "..."          API key from your ZelTrade dashboard (required)
        set zeltradecode_webhook "..."      Discord webhook for the redeem log (optional, "" = off)
]]

Config = {}

Config.Framework = 'auto' -- 'auto' | 'qbox' | 'qb' | 'esx'
Config.Locale = 'auto'    -- 'auto' (player's GTA language) | 'es' | 'en'

Config.ApiUrl = 'https://jvlstore.site/fivem/api'

Config.Branding = {
    ServerName = 'JVL MediaCode',
    LogoUrl = 'https://r2.fivemanage.com/X1XK135fBbC6NDyRj5dwS/logomediacode.png', -- '' = icon
    BannerUrl = 'https://r2.fivemanage.com/plDaVyUnqzswB27k97G3U/CumbreBanner.png', -- image on top of the panel ('' = gradient)
}

-- What the redeemed amount gives the player
--   'coins'   JVLCoins (jvl_playtime)
--   'account' money account: Qbox / QBCore 'cash' | 'bank' | 'crypto'... ESX 'money' | 'bank' | 'black_money' | 'coin'...
--   'item'    inventory item (name = item name)
Config.Reward = { type = 'coins', name = 'bank' }

-- NPC
Config.Ped = {
    model = 'a_m_m_business_01',
    coords = vector4(-1277.1866, -568.8777, 31.7136, 80.7096), -- x, y, z, heading
    scenario = 'WORLD_HUMAN_CLIPBOARD', -- '' = stand still
}

Config.Blip = { enabled = true, sprite = 605, color = 3, scale = 0.7 }

Config.Target = 'auto'     -- 'auto' | 'ox_target' | 'qb-target' | 'key' ([E] near the NPC)
Config.KeyDistance = 2.0   -- 'key' mode: meters to show the prompt
Config.MaxDistance = 5.0   -- server: max meters from the NPC to redeem

-- Anti brute force (server)
Config.Cooldown = 5                                -- seconds between tries per player
Config.MaxFails = { count = 5, minutes = 15 }      -- wrong codes before that player is locked out for a while

-- ─── INTEGRATION ─────────────────────────────────────────────────────────────
--- Client notification. kind: 'success' | 'error' | 'info'
function Notify(message, kind)
    if GetResourceState('jvl_notify') == 'started' then
        exports.jvl_notify:ShowNotification(kind or 'info', 'ZelTrade', message, 5000)
    elseif GetResourceState('ox_lib') == 'started' then
        TriggerEvent('ox_lib:notify', { title = 'ZelTrade', description = message, type = kind == 'info' and 'inform' or kind })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
    -- exports['okokNotify']:Alert('ZelTrade', message, 5000, kind or 'info')
    -- TriggerEvent('QBCore:Notify', message, kind == 'info' and 'primary' or kind, 5000)
    -- TriggerEvent('esx:showNotification', message)
    -- exports['wasabi_notify']:notify('ZelTrade', message, 5000, kind or 'info')
end

--- 'key' mode prompt
function ShowTextUI(message)
    if GetResourceState('jvl_textui') == 'started' then
        exports.jvl_textui:Show(message, { icon = 'fa-solid fa-gift' })
    elseif GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:showTextUI(message, { icon = 'gift' })
    end
    -- exports['okokTextUI']:Open(message, 'darkblue', 'left')
    -- exports['qb-core']:DrawText(message, 'left')
    -- ESX.TextUI(message)
end

function HideTextUI()
    if GetResourceState('jvl_textui') == 'started' then
        exports.jvl_textui:Hide()
    elseif GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:hideTextUI()
    end
    -- exports['okokTextUI']:Close()
    -- exports['qb-core']:HideText()
    -- ESX.HideUI()
end
