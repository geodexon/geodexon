fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}


files {
    'Fuel/GasStations.json'
}

client_script {
    '@geo/Task/cl_task.lua',
    '@geo-shared/client.lua',
    '@geo-menu/client.lua',
    '**/cl_*.lua'
}

server_script {
    '@geo/Task/sv_task.lua',
    '@geo-shared/sv_shared.lua',
    '**/sv_*.lua'
}