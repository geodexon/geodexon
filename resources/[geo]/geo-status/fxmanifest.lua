fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

shared_script {
    '**/sh_*.lua'
}

client_script {
    '@geo-global/client.lua',
    '**/cl_*.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '**/sv_*.lua'
}

files {
    'Controller/statuses.json',
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}
ui_page 'html/index.html'