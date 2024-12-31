fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

client_script {
    '@geo-shared/client.lua',
    '@geo-menu/client.lua',
    '@geo/Task/cl_task.lua',
    'Shared/shared.lua',
    'Shared/client.lua' ,
    'Police/shared.lua',
    'Police/client.lua',
    'Police/MDT/cl_mdt.lua',
    'EMS/client.lua',
    'EMS/Hospital/client.lua',
    'EMS/Triage/cl_triage.lua',
    'Evidence/cl_evidence.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'Shared/shared.lua',
    'Shared/server.lua' ,
    'Police/shared.lua',
    'Police/server.lua',
    'Police/MDT/sv_mdt.lua',
    'EMS/server.lua',
    'EMS/Hospital/server.lua',
    'EMS/Triage/sv_triage.lua',
    'Evidence/sv_evidence.lua',
    'html/scripts/charges.js',
}

files {
    'html/index.html',
    'html/scripts/*.js',
    'html/style.css',
    'html/SAOWelcome-Regular.otf',
    'Police/MDT/charges.json',
    'html/img/*.png',
    'html/img/*.gif'
  }
  
ui_page 'html/index.html'

