fx_version "cerulean"

description "A better document management script"
author "K5 Scripts"
version '1.3.4'
update "Removed issuer job from citizen documents, added custom name column to received documents"
repository 'https://github.com/kac5a/k5_documents'

lua54 'yes'

games {
  "gta5",
}

ui_page 'web/build/index.html'

client_scripts {
  '@geo-shared/client.lua',
  '@geo/Task/cl_task.lua',
  "config.lua",
  "client/**/*"
}
server_scripts {
  '@geo-shared/sv_shared.lua',
  '@geo/Task/sv_task.lua',
  "config.lua",
  "server/**/*"
}

files {
  'web/build/index.html',
  'web/build/**/*'
}
