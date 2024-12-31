fx_version 'cerulean'
games { 'gta5' }

dependencies {
    'geo-shared'
}

shared_script {
    'Skills/**/sh_*.lua',
    'Quests/**/sh_*.lua',
    'Events/**/sh_*.lua',
}

client_script {
    '@geo-global/client.lua',
    '@geo-menu/client.lua',
    '@geo/Task/cl_task.lua',
    'Skills/**/cl_*.lua',
    'Quests/**/cl_*.lua',
    'Events/**/cl_*.lua',
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'Skills/**/sv_*.lua',
    'Quests/**/sv_*.lua',
    'Events/**/sv_*.lua',
}

files {
    'Quests/Controller/Quests.json',
    '**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
    'peds.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'
data_file 'PED_METADATA_FILE' 'peds.meta'

data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
