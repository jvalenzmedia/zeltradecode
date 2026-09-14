fx_version 'cerulean'
game      'gta5'

lua54 'yes'

name        'zeltradecode'
description 'ZelTrade — Sistema de canje de códigos'
author      'JVL MediaCode'
version     '1.0.0'

shared_scripts {
    'config.lua',
}

server_scripts {
    'server.lua',
}

client_scripts {
    'client.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

dependencies {
    'ox_target',
}

