fx_version 'bodacious'
games { 'gta5' }

files {
    'items/*.json',
    'new_overlays.xml',
	'shop_tattoo.meta'
}

client_script {
    '@geo-global/client.lua',
    '@geo/Task/cl_task.lua',
    '@geo-menu/client.lua',
    'client.lua'
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'server.lua'
}