fx_version 'cerulean'
game 'gta5'

description 'Custom Mechanic Job for Qbox'
version '1.0.0'
author 'Antigravity'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/mods.lua',
    'client/installation.lua',
    'client/towing.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/images/*.png'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
