--[[
    Server: the only side that talks to the ZelTrade API (the key never reaches the players).
    Checks the code, the distance to the NPC, a cooldown and a fail limit, then gives the reward.
    If the code was accepted but the reward could not be given (player left), it is kept per character
    (KVP pendiente:<id>) and given on their next login.
]]

local apiKey = GetConvar('zeltrade_api_key', '')
local webhook = GetConvar('zeltradecode_webhook', '')

local ultimoIntento = {} -- [source] = os.time()
local fallos = {}        -- [source] = { count, since }
local enCurso = {}       -- [source] = true while the API answers

-- ─── FRAMEWORK BRIDGE ────────────────────────────────────────────────────────
local QBCore, ESX
if Framework == 'qb' then QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'esx' then ESX = exports.es_extended:getSharedObject() end

local function jugador(source)
    if Framework == 'qbox' then return exports.qbx_core:GetPlayer(source) end
    if Framework == 'qb' then return QBCore.Functions.GetPlayer(source) end
    if Framework == 'esx' then return ESX.GetPlayerFromId(source) end
end

--- Character id (citizenid / ESX identifier), nil when the character is not loaded.
local function idPersonaje(source)
    local p = jugador(source)
    if not p then return end
    if Framework == 'esx' then return p.identifier end
    return p.PlayerData and p.PlayerData.citizenid
end

--- Gives `amount` of Config.Reward to an online player. Returns true when it was given.
local function darRecompensa(source, amount)
    local r = Config.Reward
    if r.type == 'coins' then
        return GetResourceState('jvl_playtime') == 'started' and exports.jvl_playtime:addCoins(source, amount) == true
    end
    if r.type == 'item' and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, r.name, amount) and true or false
    end
    local p = jugador(source)
    if not p then return false end
    if r.type == 'account' then
        if Framework == 'esx' then p.addAccountMoney(r.name, amount, 'zeltrade') return true end
        return p.Functions.AddMoney(r.name, amount, 'zeltrade') ~= false
    elseif r.type == 'item' then
        if Framework == 'esx' then p.addInventoryItem(r.name, amount) return true end
        return p.Functions.AddItem(r.name, amount) ~= false
    end
    return false
end

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
--- ok, locale key, args (or `text` from the API)
local function responder(source, ok, key, args, text)
    TriggerClientEvent('zeltradecode:resultado', source, ok, key, args or {}, text)
end

local function log(title, lines, color)
    print(('[zeltradecode] %s | %s'):format(title, table.concat(lines, ' | ')))
    if webhook == '' then return end
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({ username = 'ZelTrade', embeds = { {
        title = title, description = table.concat(lines, '\n'), color = color or 3447003,
        footer = { text = os.date('%Y-%m-%d %H:%M:%S') },
    } } }), { ['Content-Type'] = 'application/json' })
end

local function cercaDelNpc(source)
    local ped = GetPlayerPed(source)
    return ped ~= 0 and #(GetEntityCoords(ped) - Config.Ped.coords.xyz) <= Config.MaxDistance
end

--- Seconds left of the fail lockout (0 = free).
local function bloqueado(source)
    local f = fallos[source]
    if not f or f.count < Config.MaxFails.count then return 0 end
    local left = f.since + Config.MaxFails.minutes * 60 - os.time()
    if left <= 0 then fallos[source] = nil return 0 end
    return left
end

local function sumarFallo(source)
    local f = fallos[source]
    if not f or os.time() - f.since > Config.MaxFails.minutes * 60 then f = { count = 0, since = os.time() } end
    f.count = f.count + 1
    fallos[source] = f
end

local function guardarPendiente(id, amount)
    local key = 'pendiente:' .. id
    SetResourceKvpInt(key, GetResourceKvpInt(key) + amount)
end

-- ─── REDEEM ──────────────────────────────────────────────────────────────────
RegisterNetEvent('zeltradecode:canjear', function(raw)
    local source = source
    if enCurso[source] then return end
    local code = LimpiarCodigo(raw)
    if not code then return responder(source, false, 'err_invalid') end
    if apiKey == '' then return responder(source, false, 'err_unavailable') end
    if not cercaDelNpc(source) then return responder(source, false, 'err_far') end

    local lock = bloqueado(source)
    if lock > 0 then return responder(source, false, 'err_locked', { math.ceil(lock / 60) }) end
    local now = os.time()
    if ultimoIntento[source] and now - ultimoIntento[source] < Config.Cooldown then
        return responder(source, false, 'err_wait', { Config.Cooldown - (now - ultimoIntento[source]) })
    end
    ultimoIntento[source] = now

    local id = idPersonaje(source)
    if not id and Framework ~= 'standalone' then return responder(source, false, 'err_unavailable') end
    id = id or GetPlayerIdentifierByType(source, 'license') or tostring(source)
    local name = GetPlayerName(source) or '?'

    enCurso[source] = true
    PerformHttpRequest(Config.ApiUrl .. '/redeem-code.php', function(status, body)
        enCurso[source] = nil
        local ok, data = pcall(json.decode, body or '')
        data = ok and type(data) == 'table' and data or {}
        local amount = math.floor(tonumber(data.amount) or 0)

        if status ~= 200 or not data.success or amount <= 0 then
            sumarFallo(source)
            local apiError = type(data.error) == 'string' and data.error:sub(1, 120) or nil
            if status == 0 or status >= 500 then return responder(source, false, 'err_api') end
            return responder(source, false, 'err_rejected', nil, apiError)
        end

        fallos[source] = nil
        if GetPlayerName(source) and darRecompensa(source, amount) then
            log('Código canjeado', { name .. ' (' .. id .. ')', code, amount .. ' ' .. Config.Reward.type }, 3066993)
            return responder(source, true, 'ok_redeemed', { amount, L('reward_' .. Config.Reward.type) })
        end
        -- accepted by ZelTrade but not given: keep it for the next login
        guardarPendiente(id, amount)
        log('Código canjeado, recompensa pendiente', { name .. ' (' .. id .. ')', code, amount .. ' ' .. Config.Reward.type }, 15105570)
        if GetPlayerName(source) then responder(source, false, 'err_pending') end
    end, 'POST', json.encode({ api_key = apiKey, code = code, player_id = id }), { ['Content-Type'] = 'application/json' })
end)

-- ─── PENDING REWARDS ON LOGIN ────────────────────────────────────────────────
local function entregarPendiente(source)
    SetTimeout(5000, function() -- let other resources (jvl_playtime coins) load the character first
        local id = idPersonaje(source)
        if not id then return end
        local key = 'pendiente:' .. id
        local amount = GetResourceKvpInt(key)
        if amount <= 0 or not darRecompensa(source, amount) then return end
        DeleteResourceKvp(key)
        log('Recompensa pendiente entregada', { (GetPlayerName(source) or '?') .. ' (' .. id .. ')', amount .. ' ' .. Config.Reward.type }, 3066993)
        responder(source, true, 'ok_pending', { amount, L('reward_' .. Config.Reward.type) })
    end)
end

if Framework == 'esx' then
    AddEventHandler('esx:playerLoaded', function(playerId) entregarPendiente(playerId) end)
else
    AddEventHandler('QBCore:Server:OnPlayerLoaded', function() entregarPendiente(source) end)
end

AddEventHandler('playerDropped', function()
    local source = source
    ultimoIntento[source], fallos[source], enCurso[source] = nil, nil, nil
end)

-- ─── LICENSE CHECK ───────────────────────────────────────────────────────────
CreateThread(function()
    if apiKey == '' then
        return print('^1[zeltradecode] Falta la API key: agrega  set zeltrade_api_key "..."  en un cfg del servidor^0')
    end
    PerformHttpRequest(Config.ApiUrl .. '/verify-license.php', function(status, body)
        local ok, data = pcall(json.decode, body or '')
        data = ok and type(data) == 'table' and data or {}
        if status == 200 and data.valid then
            print(('^2[zeltradecode] Licencia válida - %s^0'):format(data.server_name or ''))
        else
            print(('^1[zeltradecode] Licencia inválida: %s^0'):format(data.error or ('HTTP ' .. tostring(status))))
        end
    end, 'POST', json.encode({ api_key = apiKey }), { ['Content-Type'] = 'application/json' })
end)
