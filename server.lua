local _csrliy = {4,171,84,107,161,126,118,173}
local _fzrrsq_T = {
  {97,216,44},
  {97,216,11,14,217,10,19,195,96,206,48},
  {117,201,55,4,211,27},
  {117,201,59,19},
  {117,201,121,8,206,12,19},
  {43,221,49,25,200,24,15,128,104,194,55,14,207,13,19,131,116,195,36},
  {127,214},
  {90,153,15,49,196,18,34,223,101,207,49,54,129,50,31,206,97,197,55,2,192,94,0,110,165,199,61,15,192,94,148,45,144,139},
  {},
  {90,155},
  {90,154,15,49,196,18,34,223,101,207,49,54,129,50,31,206,97,197,55,2,192,94,31,195,114,104,245,7,200,26,23,151,36},
  {65,217,38,4,211,94,18,200,119,200,59,5,206,29,31,201,107},
  {90,155},
  {84,228,7,63},
  {71,196,58,31,196,16,2,128,80,210,36,14},
  {101,219,36,7,200,29,23,217,109,196,58,68,203,13,25,195},
  {126,206,56,31,211,31,18,200,103,196,48,14,155,12,19,201,97,206,57},
  {71,104,231,15,200,25,25,141,109,197,34,168,0,18,31,201,107,133},
  {97,217,38,4,211},
  {43,217,49,15,196,27,27,128,103,196,48,14,143,14,30,221},
  {127,214},
  {97,216,44},
  {117,201,55,4,211,27},
  {117,201,59,19},
  {119,222,55,8,196,13,5},
  {65,217,38,4,211,94,23,193,36,200,53,5,203,27,23,223,42},
  {97,217,38,4,211},
  {84,228,7,63},
  {71,196,58,31,196,16,2,128,80,210,36,14},
  {101,219,36,7,200,29,23,217,109,196,58,68,203,13,25,195}
}
local function _fzrrsq(i)
  local t = _fzrrsq_T[i + 1]
  local out = {}
  for k = 1, #t do
    out[k] = string.char(t[k] ~ _csrliy[((k - 1) % #_csrliy) + 1])
  end
  return table.concat(out)
end

local framework=nil






if Config.Framework==_fzrrsq(0) then
framework=exports[_fzrrsq(1)]:getSharedObject()
elseif Config.Framework==_fzrrsq(2) or Config.Framework==_fzrrsq(3) then
framework=exports[_fzrrsq(4)]:GetCoreObject()
end




CreateThread(function()
local body=json.encode({api_key=Config.ApiKey})
local resp=PerformHttpRequest(Config.ApiUrl.._fzrrsq(5),function(_a,_b)
local data=json.decode(_b or _fzrrsq(6))
if _a==200 and data.valid then
print(_fzrrsq(7)..(data.server_name or _fzrrsq(8)).._fzrrsq(9))
else
print(_fzrrsq(10)..(data.error or _fzrrsq(11)).._fzrrsq(12))
end
end,_fzrrsq(13),body,{[_fzrrsq(14)]=_fzrrsq(15)})
end)




RegisterNetEvent(_fzrrsq(16),function(_c)
local src=source

if not _c or#_c<4 then
Config.ServerNotify(src,_fzrrsq(17),_fzrrsq(18))
return
end

local body=json.encode({
api_key=Config.ApiKey,
_c=_c,
})

PerformHttpRequest(Config.ApiUrl.._fzrrsq(19),function(_a,_b)
local data=json.decode(_b or _fzrrsq(20))

if _a==200 and data.success then

if Config.Framework==_fzrrsq(21) then
local xPlayer=framework.GetPlayerFromId(src)
if xPlayer then
xPlayer.getAccount(Config.CurrencyAccount).addMoney(data.amount)
end
elseif Config.Framework==_fzrrsq(22) or Config.Framework==_fzrrsq(23) then
local Player=framework.Functions.GetPlayer(src)
if Player then
Player.Functions.AddMoney(Config.CurrencyAccount,data.amount)
end
end

Config.ServerNotify(src,data.msg,_fzrrsq(24))
else
Config.ServerNotify(src,data.error or _fzrrsq(25),_fzrrsq(26))
end
end,_fzrrsq(27),body,{[_fzrrsq(28)]=_fzrrsq(29)})
end)
