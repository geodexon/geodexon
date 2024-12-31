fx_version 'bodacious'
games { 'gta5' }

dependencies {
   'geo-shared'
}

shared_scripts {
   '**/sh_*.lua',
}

client_scripts {
   '@geo-global/client.lua',
   "@geo-menu/client.lua",
   '@geo/Task/cl_task.lua',
   '**/cl_*.lua',
}

server_scripts {
   '@geo-shared/sv_shared.lua',
   '@geo/Task/sv_task.lua',
   '**/sv_*.lua',
}

files {
   'html/index.html',
   'html/**/*.js',
   'html/**/*.css',
   'html/**/*.png',
   'html/**/*.jpg',
   'html/**/*.svg',
   'html/**/*.mp3',
   'html/SAOWelcome-Regular.otf'
 }
 
 ui_page 'html/index.html'
 lua_54 'yes'