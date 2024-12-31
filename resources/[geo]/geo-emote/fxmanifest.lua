fx_version 'bodacious'
games { 'gta5' }

dependencies {
    'geo-shared'
}

files {
    'propsets.meta',
    'conditionalanims.meta',
}

data_file 'AMBIENT_PROP_MODEL_SET_FILE' 'propsets.meta'
data_file 'CONDITIONAL_ANIMS_FILE' 'conditionalanims.meta'

shared_script {
    'sh_*.lua'
}

client_script {
    '@geo-global/client.lua',
    '@geo/Task/cl_task.lua',
    '@geo-menu/client.lua',
    'cl_*.lua',
}

server_script {
    '@geo-shared/sv_shared.lua',
    '@geo/Task/sv_task.lua',
    'sv_*.lua',
    '**/sv_*.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/taymckenzienz_rpemotes.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brummie_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'bzzz_camp_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/apple_1.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/kaykaymods_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/knjgh_pizzas.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/natty_props_lollipops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/ultra_ringcase.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/pata_props.ytyp'