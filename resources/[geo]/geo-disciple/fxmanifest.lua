fx_version 'bodacious'
games { 'gta5' }
lua54 'yes'

dependencies {
    'geo-inventory'
}

shared_scripts {
    'Shared/sh_*.lua'
}

client_script {
    '@geo-global/client.lua',
    '@geo/Task/cl_task.lua',
    'Client/cl_*.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'Server/sv_*.lua'
}

files {
    'html/index.html',
    'html/scripts/*.js',
    'html/style.css',
    'html/css/*.css',
    'html/img/*.png',
    'html/img/*.gif'
  }
  
ui_page 'html/index.html'

