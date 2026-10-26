fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'zeltradecode'
author 'JVL MediaCode'
description 'ZelTrade Code - Redeem ZelTrade store purchase codes at an NPC (Qbox, QBCore, ESX)'
version '2.0.1'

-- Optional: ox_target / qb-target, jvl_playtime (JVLCoins), jvl_notify, jvl_textui. No fxmanifest dependencies.
shared_scripts {
    'locales/*.lua',
    'config.lua',
    'shared.lua',
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/*.css',
    'web/*.js',
}
