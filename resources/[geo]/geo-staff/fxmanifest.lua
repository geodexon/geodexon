fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

client_script {
    '@geo-global/client.lua',
    '@geo-menu/client.lua',
    'client.lua',
    'cl_dev.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    'server.lua',
    'sv_dev.lua'
}
