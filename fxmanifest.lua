fx_version 'adamant'

game 'gta5'

description 'ESX GangScript'

version '1.0.0'

server_scripts {
  '@es_extended/locale.lua',
  'locales/pl.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/pl.lua',
  'config.lua',
  'client/main.lua'
}
