fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

shared_script {
    'Gathering/shared.lua',
    'Crafting/shared.lua',
    'Illegal/**/sh_*.lua',
    'Standard/**/sh_*.lua',
    'Casino/**/sh_*.lua'
}

client_script {
    '@geo-global/client.lua',
    '@geo-menu/client.lua',
    '@geo/Task/cl_task.lua',
    '@mka-lasers/client/client.lua',
    'Controllers/cl_controller.lua',
    'Standard/**/cl_*.lua',
    'Illegal/BankTruck/config.lua',
    'Illegal/Vangelico/config.lua',
    'Illegal/**/cl_*.lua',
    'Casino/**/cl_*.lua',
    'ES/cl_es.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'Controllers/Jobs.lua',
    'Standard/**/sv_*.lua',
    'Illegal/BankTruck/config.lua',
    'Illegal/Vangelico/config.lua',
    'Illegal/**/sv_*.lua',
    'Casino/**/sv_*.lua',
    'Loot/sv_loot.lua',
    'ES/sv_es.lua'
}

files {
    '_html/index.html',
    '_html/script.js',
    '_html/style.css',
    '_html/img/*.png',
    '_html/trafficking.js',
    '_html/trafficking.css',
    '_html/SAOWelcome-Regular.otf',
}

ui_page '_html/index.html'
