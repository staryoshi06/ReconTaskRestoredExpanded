america--credit: https://github.com/JamesWilko/Payday-2-BLT/blob/crimefest/example_mods/JsonMenuExample/json_example.lua
_G.StarReconMenu = _G.StarReconMenu or {}
StarReconMenu._path = ModPath
StarReconMenu._data_path = SavePath .. "ReconTaskRestoredAndExpanded.json"
StarReconMenu._data = {}

StarReconMenu._enemy_sets = {
    STANDARD = 1,
    FIXED_DIFF = 2,
    FIXED = 3,
    SWAT = 4,
    NONE = 5,
    ORIGINAL = 6
}

StarReconMenu._assault_conditions = {
    NEVER = 1,
    HOSTAGES = 2,
    ANY = 3,
    ALWAYS = 4
}

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
    --enemies
    if not StarReconMenu._data.enemy_set_america then StarReconMenu._data.enemy_set_america = StarReconMenu._enemy_sets.STANDARD end
    if not StarReconMenu._data.enemy_set_russia then StarReconMenu._data.enemy_set_russia = StarReconMenu._enemy_sets.STANDARD end
    if not StarReconMenu._data.enemy_set_zombie then StarReconMenu._data.enemy_set_zombie = StarReconMenu._enemy_sets.STANDARD end
    if not StarReconMenu._data.enemy_set_murky then StarReconMenu._data.enemy_set_murky = StarReconMenu._enemy_sets.STANDARD end
    if not StarReconMenu._data.enemy_set_federales then StarReconMenu._data.enemy_set_federales = StarReconMenu._enemy_sets.STANDARD end
    if not StarReconMenu._data.no_lights then StarReconMenu._data.no_lights = false end
    if not StarReconMenu._data.bronco_guy then StarReconMenu._data.bronco_guy = false end

    --behaviour
    if not StarReconMenu._data.sneaky_recon then StarReconMenu._data.sneaky_recon = false end
    if not StarReconMenu._data.bag_fix then StarReconMenu._data.bag_fix = false end
    if not StarReconMenu._data.gangster_no_flee then StarReconMenu._data.gangster_no_flee = false end
    if not StarReconMenu._data.assault_condition then StarReconMenu._data.assault_condition = StarReconMenu._assault_conditions.NEVER end

    --reinforce
    if not StarReconMenu._data.reinforce_allowed then StarReconMenu._data.reinforce_allowed = false end
end

Hooks:Add("LocalizationManagerPostInit", "star_recon_localise_menu", function( loc )
	loc:load_localization_file( StarReconMenu._path .. "menu/en.json")
end)

Hooks:Add( "MenuManagerInitialize", "star_recon_init_menu", function( menu_manager )
    -- enemies
    
    MenuCallbackHandler.clbk_recon_enemy_set_america = function(self, item)
       StarReconMenu._data.enemy_set_america = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_enemy_set_russia = function(self, item)
       StarReconMenu._data.enemy_set_russia = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_enemy_set_zombie = function(self, item)
       StarReconMenu._data.enemy_set_zombie = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_enemy_set_murky = function(self, item)
       StarReconMenu._data.enemy_set_murky = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_enemy_set_federales = function(self, item)
       StarReconMenu._data.enemy_set_federales = item:value()
       StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_no_lights = function(self, item)
        StarReconMenu._data.no_lights = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end
    
    MenuCallbackHandler.clbk_recon_bronco_guy = function(self, item)
        StarReconMenu._data.bronco_guy = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end

    --behaviour

    MenuCallbackHandler.clbk_recon_assault_condition = function(self, item)
        StarReconMenu._data.assault_condition = item:value()
        StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_sneaky_recon = function(self, item)
        StarReconMenu._data.sneaky_recon = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end
    
    MenuCallbackHandler.clbk_recon_bag_fix = function(self, item)
        StarReconMenu._data.bag_fix = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end

    MenuCallbackHandler.clbk_recon_gangster_no_flee = function(self, item)
        StarReconMenu._data.gangster_no_flee = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end

    --reinforce

    MenuCallbackHandler.clbk_recon_allow_reinforce = function(self, item)
        StarReconMenu._data.reinforce_allowed = (item:value() == "on" and true or false)
        StarReconMenu:Save()
    end

    StarReconMenu:Load()

    MenuHelper:LoadFromJsonFile(StarReconMenu._path .. "menu/menu.json", StarReconMenu, StarReconMenu._data)
end)