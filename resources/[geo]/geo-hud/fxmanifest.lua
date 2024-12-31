fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

client_script  {
    '@geo-global/client.lua',
    'client.lua'
}

server_script {
    'server.lua'
}

ui_page {
    'html/index.html',
}

files {
	'html/index.html',
	'html/script.js', 
    'html/style.css',
    'html/pics/*.png',
    'html/pics/*.svg'
}
