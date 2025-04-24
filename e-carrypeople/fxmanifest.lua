fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'EMIS'

client_scripts {
    'config.lua',
    'locales/*.lua', 
    'client.lua'
}

server_script "server.lua"

shared_scripts {
    '@ox_lib/init.lua'
}

files {
    'locales/lt.lua',
    'locales/en.lua'
}