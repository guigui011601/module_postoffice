fx_version 'cerulean'
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'ALTITUDE-DEV.COM by Shepard#1395'
version '1.3.1'
description 'module_postoffice the largest system postOffice in VORP !'

ui_page "html/index.html"

files { 
    'html/index.html',
    'html/design/*.png',
    'html/design/*.jpg',
    'html/core.css',
    'html/core.js'
}

client_scripts {
    'config.lua',
    'modules/client-side.lua'
}

server_scripts{
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'modules/server-side.lua' 
}

lua54 'yes'
escrow_ignore {
    'config.lua',
    'tutorial/*',
    'html/*'
}
dependency '/assetpacks'