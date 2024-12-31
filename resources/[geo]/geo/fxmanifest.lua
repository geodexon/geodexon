fx_version 'bodacious'
games { 'gta5' }

client_scripts {
   '@geo-global/client.lua',
   "@geo-menu/client.lua",
   'Task/cl_task.lua',
   'chat.lua',
   "cl_login.lua",
   'Clothing/client.lua',
   'death.lua',
   "Queue/shared/sh_queue.lua",
}

server_scripts {
   '@geo-shared/sv_shared.lua',
   'Task/sv_task.lua',
   "sv_login.lua",
   'Clothing/server.lua',
   "Queue/server/sv_queue_config.lua",
   "Queue/connectqueue.lua",
   "Queue/shared/sh_queue.lua",
}