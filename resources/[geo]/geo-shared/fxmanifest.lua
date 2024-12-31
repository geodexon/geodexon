fx_version 'bodacious'
games { 'gta5' }

shared_scripts {
    'lib.lua'
}

client_script {
    'client.lua',
    'notif.lua',
    'lists.lua'
}

server_script {
    'sv_shared.lua',
    'server.lua',
}

ui_page {
    'html/ui.html',
}

files {
	'html/ui.html',
	'html/js/*.js', 
    'html/css/*.css',
    'html/css/SAOWelcome-Regular.otf',
    'html/sao_menu_open.wav',
    'html/sao_menu_select.wav',
    'html/*.png',
    'html/*.wav',
    'html/*.mp3',
    'html/sounds/*.wav',
    'html/sounds/*.mp3',
    'html/helpers/helper.js',
    'html/helpers/helper.css'
}
