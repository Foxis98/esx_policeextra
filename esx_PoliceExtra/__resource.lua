resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"
lua54 'yes'

client_scripts {
	"@es_extended/locale.lua",
    "locales/en.lua", 
    "config.lua",
    "client.lua"
}
shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}