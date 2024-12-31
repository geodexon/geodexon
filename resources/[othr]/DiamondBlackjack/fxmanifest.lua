fx_version 'adamant'

game "gta5"

description "DiamondBlackjack created by Robbster"

shared_scripts {
	'sh_blackjack.lua'
}

client_scripts {
	'stream.lua',
    '@geo-shared/client.lua',
	"cl_blackjack.lua",
	"cl_casinoteleporter.lua",
}

server_scripts {
	'@geo-shared/sv_shared.lua',
	"sv_blackjack.lua"
}

data_file 'TIMECYCLEMOD_FILE' 'casino_timecyc.xml'
this_is_a_map 'yes'