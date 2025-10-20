fx_version "adamant"
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'


lua54 'yes'


name 'broken_outlaws_stool'
description 'Configurable to sit on a foldeble stool.'
author 'Broken Outlaws'
version '1.0.0'


dependencies {
  'vorp_core',
  'vorp_inventory',
}

client_scripts {
  'config.lua',
  'client/main.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}