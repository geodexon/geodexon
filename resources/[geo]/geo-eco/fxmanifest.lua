fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

client_script {
    '@geo-global/client.lua',
    '@geo-menu/client.lua',
    '@geo/Task/cl_task.lua',
    'cl_eco.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'sv_eco.lua',
}

files {
    'html/index.html',
    'html/**/*.js',
    'html/**/*.css',
    'html/img/*.png',
    'html/SAOWelcome-Regular.otf'
  }
  
ui_page 'html/index.html'



