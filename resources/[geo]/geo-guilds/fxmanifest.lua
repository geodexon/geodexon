fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

lua54 'yes'

client_script {
    '@geo-shared/client.lua',
    '@geo/Task/cl_task.lua',
    '@geo-menu/client.lua',
    'shared.lua',
    'client.lua',
    'Locks/shared.lua',
    'Locks/cl_locks.lua',
    'Mayor/cl_mayor.lua',
    'Guilds/**/sh_*.lua',
    'Guilds/**/cl_*.lua',
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'shared.lua',
    'server.lua',
    'Locks/shared.lua',
    'Locks/server.lua',
    'Mayor/sv_mayor.lua',
    'Guilds/**/sh_*.lua',
    'Guilds/**/sv_*.lua',
}
  
  
