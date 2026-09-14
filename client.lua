local _lhkgeu = {159,51,60,73,144,74,253,105}
local _dtciec_T = {
  {240,75,99,61,241,56,154,12,235},
  {229,86,80,61,226,43,153,12,192,65,89,45,245,47,144},
  {249,82,79,105,246,43,208,14,246,85,72},
  {240,67,89,39},
  {252,95,83,58,245},
  {252,95,83,58,245,31,180},
  {240,88},
  {237,86,88,44,245,39},
  {},
  {229,86,80,61,226,43,153,12,252,92,88,44,170,56,152,13,250,86,81},
  {240,88},
  {229,86,80,61,226,43,153,12,252,92,88,44,170,36,146,29,246,85,69},
  {237,86,79,60,252,62},
  {236,70,95,42,245,57,142}
}
local function _dtciec(i)
  local t = _dtciec_T[i + 1]
  local out = {}
  for k = 1, #t do
    out[k] = string.char(t[k] ~ _lhkgeu[((k - 1) % #_lhkgeu) + 1])
  end
  return table.concat(out)
end

local isOpen=false
local ped=nil




CreateThread(function()
local model=GetHashKey(Config.Ped.model)
RequestModel(model)
while not HasModelLoaded(model)do Wait(100)end

ped=CreatePed(4,model,Config.Ped.coords.x,Config.Ped.coords.y,Config.Ped.coords.z-1.0,Config.Ped.coords.w,false,true)
SetEntityInvincible(ped,true)
SetBlockingOfNonTemporaryEvents(ped,true)
FreezeEntityPosition(ped,true)
SetModelAsNoLongerNeeded(model)

exports[_dtciec(0)]:addLocalEntity(ped,{
{
name=_dtciec(1),
label=Config.Ped.label,
icon=_dtciec(2),
onSelect=function()
openUI()
end,
}
})
end)




function openUI()
if isOpen then return end
isOpen=true

SetNuiFocus(true,true)
SendNUIMessage({
action=_dtciec(3),
serverName=Config.ServerName,
serverBanner=Config.ServerBanner,
})
end




function closeUI()
if not isOpen then return end
isOpen=false
SetNuiFocus(false,false)
SendNUIMessage({action=_dtciec(4)})
end




RegisterNUICallback(_dtciec(5),function(_a,_b)
closeUI()
_b(_dtciec(6))
end)

RegisterNUICallback(_dtciec(7),function(_e,_b)
local code=tostring(_e.code or _dtciec(8)):upper()
TriggerServerEvent(_dtciec(9),code)
_b(_dtciec(10))
end)




RegisterNetEvent(_dtciec(11),function(_c,_d)
Config.ClientNotify(_c,_d)


if isOpen then
SendNUIMessage({
action=_dtciec(12),
success=_d==_dtciec(13),
msg=_c,
})
end
end)


