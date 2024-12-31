fx_version 'cerulean'
games { 'gta5' }

dependencies {
   'geo-shared'
}

shared_scripts {
   'PlayerStores/sh_store.lua'
}

client_scripts {
   '@geo-shared/client.lua',
   "@geo-menu/client.lua",
   '@geo/Task/cl_task.lua',
   'inventoruSizes.lua',
   'itemDictionary.lua',
   'cl_inventory.lua',
   'cl_itemActions.lua',
   'PlaceableObjects.lua',
   'radio.lua',
   'weapons_back.lua',
   'Stores/shared.lua',
   'Stores/client.lua',
   'Items/cl_*.lua',
   'cl_props.lua',
   'PlayerStores/cl_store.lua'
}

server_scripts {
   '@geo-shared/sv_shared.lua',
   '@geo/Task/sv_task.lua',
   'inventoruSizes.lua',
   'itemDictionary.lua',
   'sv_inventory.lua',
   'sv_itemActions.lua',
   'Stores/shared.lua',
   'Stores/server.lua',
   'PlayerStores/sv_store.lua'
}

files {
   'html/index.html',
   'html/script.js',
   'html/style.css',
   'html/img/*.png',
   'html/img/svg/*.svg',
   'html/SAOWelcome-Regular.otf'
 }
 
 ui_page 'html/index.html'