--credit: https://github.com/JamesWilko/Payday-2-BLT/blob/crimefest/example_mods/JsonMenuExample/json_example.lua
_G.StarReconMenu = _G.StarReconMenu or {}
StarReconMenu._path = ModPath
StarReconMenu._data_path = ModPath .. "menu/settings.json"
StarReconMenu._data = {}

function StarReconMenu:Save()
    local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function StarReconMenu:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "star_recon_localise_menu", function( loc )
	loc:load_localization_file( StarReconMenu._path .. "menu/en.json")
end)

Hooks:Add( "MenuManagerInitialize", "star_recon_init_menu", function( menu_manager )
    MenuCallbackHandler.clbk_recon_enemy_set = function(self, item)
       StarReconMenu._data.enemy_set = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_assault_condition = function(self, item)
        StarReconMenu._data.assault_condition = item:value()
        StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_assault_behaviour = function(self, item)
        StarReconMenu._data.assault_behaviour = item:value()
        StarReconMenu:Save()
    end

    StarReconMenu:Load()

    MenuHelper:LoadFromJsonFile(StarReconMenu._path .. "menu/menu.json", StarReconMenu, StarReconMenu._data)
end)