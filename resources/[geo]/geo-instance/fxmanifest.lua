fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

shared_scripts {
    'Apartments/sh_apartments.lua'
}

client_script {
    '@geo-menu/client.lua',
    '@geo-global/client.lua',
    '@geo/Task/cl_task.lua',
    'interiors.lua',
    'proximity.lua',
    'Instance/client.lua',
    'Housing/shared.lua',
    'Housing/client.lua',
    'Apartments/cl_apartments.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'interiors.lua',
    'Instance/server.lua',
    'Housing/shared.lua',
    'Housing/server.lua',
    'Apartments/sv_apartments.lua'
}
