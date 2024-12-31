fx_version 'cerulean'
game 'gta5'


shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    '@mka-lasers/client/client.lua',
    'client/main.lua',
}
server_script 'server/main.lua'

lua54 'yes'

escrow_ignore {
    'config.lua',
    'locales/en.lua',
    'vangelico.lua',
    'client/main.lua',
    'server/main.lua'
}

dependency '/assetpacks'