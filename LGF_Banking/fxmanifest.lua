fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Unknow'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'configuration.lua'
}

client_scripts {
    'client/modules/functions.lua',
    'client/client.lua',
    'client/modules/printer.lua',

}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/server.lua'
}

files {
    "utils/locales/*.json",
    'utils/shared.lua'
}

-- for printer props

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_electro_prop_3dprinter.ytyp'
