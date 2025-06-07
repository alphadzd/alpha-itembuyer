fx_version 'cerulean'
game 'gta5'

author 'AlphaDev'
description 'تاجر الممنوعات'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/ar.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu',
    'qb-input'
}

lua54 'yes'