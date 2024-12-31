fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

shared_scripts {
    '@geo-shared/lists.lua',
    '**/sh_*.lua'
}

client_script {
    '@geo-global/client.lua',
    '@geo-menu/client.lua',
    '@geo/Task/cl_task.lua',
    '**/cl_*.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    '**/sv_*.lua'
}
