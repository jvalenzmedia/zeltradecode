--[[
    Client: the NPC (ox_target, qb-target or [E]), the blip and the redeem panel. Only sends the code;
    the server checks everything and talks to ZelTrade.
]]

local abierto = false
local ped, blip = nil, nil

local function textos()
    local t = {}
    for k in pairs(Locales.es) do if k:sub(1, 3) == 'ui_' then t[k] = L(k) end end
    return t
end

-- ─── PANEL ───────────────────────────────────────────────────────────────────
local function abrir()
    if abierto then return end
    abierto = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        texts = textos(),
        serverName = Config.Branding.ServerName,
        logo = Config.Branding.LogoUrl,
        banner = Config.Branding.BannerUrl,
        version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
    })
end

local function cerrar()
    if not abierto then return end
    abierto = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb) cb('ok') cerrar() end)

RegisterNUICallback('redeem', function(d, cb)
    cb('ok')
    local code = LimpiarCodigo(type(d) == 'table' and d.code or nil)
    if not code then return SendNUIMessage({ action = 'result', success = false, msg = L('err_invalid') }) end
    TriggerServerEvent('zeltradecode:canjear', code)
end)

RegisterNetEvent('zeltradecode:resultado', function(ok, key, args, text)
    local msg = text or L(key, table.unpack(args or {}))
    Notify(msg, ok and 'success' or 'error')
    if abierto then SendNUIMessage({ action = 'result', success = ok, msg = msg }) end
end)

-- ─── NPC ─────────────────────────────────────────────────────────────────────
local function usarTarget()
    local t = Config.Target
    if t == 'auto' then
        t = GetResourceState('ox_target') == 'started' and 'ox_target' or GetResourceState('qb-target') == 'started' and 'qb-target' or 'key'
    end
    if t == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, { { name = 'zeltradecode', label = L('target'), icon = 'fa-solid fa-gift', distance = 2.5, onSelect = abrir } })
    elseif t == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, { options = { { label = L('target'), icon = 'fas fa-gift', action = abrir } }, distance = 2.5 })
    else
        CreateThread(function()
            local mostrando = false
            local pos = Config.Ped.coords.xyz
            while ped do
                local cerca = not abierto and #(GetEntityCoords(PlayerPedId()) - pos) <= Config.KeyDistance
                if cerca ~= mostrando then
                    mostrando = cerca
                    if cerca then ShowTextUI(L('key_prompt')) else HideTextUI() end
                end
                if cerca and IsControlJustReleased(0, 38) then abrir() end -- 38 = E
                Wait(cerca and 0 or 500)
            end
            if mostrando then HideTextUI() end
        end)
    end
end

CreateThread(function()
    local c = Config.Ped
    local model = joaat(c.model)
    if not IsModelInCdimage(model) then return print(('^1[zeltradecode] Modelo de NPC inválido: %s^0'):format(c.model)) end
    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return print('^1[zeltradecode] No cargó el modelo del NPC^0') end
        Wait(50)
    end

    ped = CreatePed(4, model, c.coords.x, c.coords.y, c.coords.z - 1.0, c.coords.w, false, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    if c.scenario and c.scenario ~= '' then TaskStartScenarioInPlace(ped, c.scenario, 0, true) end
    usarTarget()

    local b = Config.Blip
    if b.enabled then
        blip = AddBlipForCoord(c.coords.x, c.coords.y, c.coords.z)
        SetBlipSprite(blip, b.sprite)
        SetBlipColour(blip, b.color)
        SetBlipScale(blip, b.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(L('blip'))
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    if abierto then SetNuiFocus(false, false) end
    if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
    if blip then RemoveBlip(blip) end
    ped = nil
end)
