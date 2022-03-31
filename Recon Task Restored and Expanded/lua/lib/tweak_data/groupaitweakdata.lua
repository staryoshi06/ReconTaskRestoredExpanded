local tweak_data_ref = nil
local data_path = ModPath .. "menu/settings.json"

function GroupAITweakData:getHeistType()
    local level_id = Global.level_data and Global.level_data.level_id -- referenced from Assault Tweaks Standalone

    if not level_id then
        return nil
    elseif level_id == "firestarter_2" or level_id == "hox_2" or level_id == "hox_3" then
        return "fbi"
    elseif level_id == "welcome_to_the_jungle_2" or level_id == "chew" or level_id == "chca" or level_id == "bph" or (self.rtre_menu_data and self.rtre_menu_data.enemy_set == 2) then
        return "remote"
    elseif level_id == "rvd1" or level_id == "rvd2" then
        return "la"
    elseif level_id == "chas" or level_id == "sand" or level_id == "pent" then
        return "sanfran"
    else
        return "normal"
    end
end

Hooks:PreHook(GroupAITweakData, "init", "star_recon_init_groupaitweakdata", function(self, tweak_data)
    tweak_data_ref = tweak_data
    self.rtre_menu_data = {}
    -- get menu data
    local file = io.open( data_path, "r" )
    if file then
        self.rtre_menu_data = json.decode( file:read("*all") )
        file:close()
    end
    if not self.rtre_menu_data.enemy_set then self.rtre_menu_data.enemy_set = 1 end
    if not self.rtre_menu_data.assault_condition then self.rtre_menu_data.assault_condition = 1 end
    if not self.rtre_menu_data.assault_behaviour then self.rtre_menu_data.assault_behaviour = 1 end
end)

--Define recon units and add to original
Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "star_recon_init_unit_categories", function(self, difficulty_index)
    local access_type_walk_only = {
		walk = true
	}
    local access_type_all = {
		acrobatic = true,
		walk = true
	}

    --check for whether required packages are loaded for murky units. if not, swap out
    --if we don't then host will crash. if we force load packages, clients without mod will not see enemies
    --I don't know the memory cost of checking this unfortunately
    local murky_ump = nil
    local murky_c45 = nil
    local murky_mp5 = nil

    --from gamesetup.lua
    local lvl_tweak_data = tweak_data_ref and Global.level_data and Global.level_data.level_id and tweak_data_ref.levels[Global.level_data.level_id]
    local level_package = lvl_tweak_data and lvl_tweak_data.package

    if type(level_package) == "table" then
        for _, package in ipairs(level_package) do
            -- i don't feel like making a table so this bad if statement will have to do
            -- i can't just say if not job_bph because custom packages from custom heists would crash
            if not murky_c45 and (package == "packages/narr_jerry1" or package == "packages/dlcs/vit/job_vit" or package == "packages/job_mex" or package == "packages/job_mex2" or package == "packages/job_des") then
                murky_c45 = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
            end
    
            if not murky_ump and (murky_c45 or package == "packages/dlcs/bph/job_bph") then
                murky_ump = Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security")
            end
        end
    else
        if (level_package and (level_package == "packages/narr_jerry1" or level_package == "packages/dlcs/vit/job_vit" or level_package == "packages/job_mex" or level_package == "packages/job_mex2" or level_package == "packages/job_des")) then
            murky_c45 = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
        end

        if murky_c45 or (level_package and level_package == "packages/dlcs/bph/job_bph") then
            murky_ump = Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security")
        end
    end

    murky_mp5 = Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light")
    
    if not murky_ump then
        murky_ump = murky_mp5
    end
    if not murky_c45 then
        murky_c45 = murky_mp5
    end

    local is_classic = self.rtre_menu_data and self.rtre_menu_data.enemy_set == 3

    --Normal
    if difficulty_index <= 2 then
        self.unit_categories.RECON_light = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
                    Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2")
                },
                murkywater = {
                    murky_c45
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
                }
            },
            access = access_type_walk_only
        }

        self.unit_categories.RECON_heavy = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
                    Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
                },
                murkywater = {
                    murky_c45
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
                }
            },
            access = access_type_walk_only
        }

    --Hard/Very Hard
    elseif difficulty_index <= 4 and not is_classic then
        self.unit_categories.RECON_light = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
                    Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
                },
                murkywater = {
                    murky_c45
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
                }
            },
            access = access_type_walk_only
        }

        self.unit_categories.RECON_heavy = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")

                },
                murkywater = {
                    murky_mp5

                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")

                }
            },
            access = access_type_walk_only
        }

    --Overkill/Mayhem
    elseif difficulty_index <= 6 then
        self.unit_categories.RECON_light = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
                },
                murkywater = {
                    murky_c45,
                    murky_mp5
                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                }
            },
            access = access_type_all
        }

        self.unit_categories.RECON_heavy = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                    Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3"),
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
                },
                murkywater = {
                    murky_mp5,
                    murky_ump
                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                    Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")

                }
            },
            access = access_type_all
        }

    --Death Wish/Death Sentence
    else
        self.unit_categories.RECON_light = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
                },
                murkywater = {
                    murky_mp5
                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                }
            },
            access = access_type_all
        }

        self.unit_categories.RECON_heavy = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
                },
                murkywater = {
                    murky_ump
                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                }
            },
            access = access_type_all
        }
    end

    --for Classic style; police are mostly the same as normal difficulty except for russia faction and access type
    self.unit_categories.RECON_police_light = {
        unit_types = {
            america = {
                Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
                Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")
            },
            russia = {
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
            },
            zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
                Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2")
            },
            murkywater = {
                murky_c45
            },
            federales = {
                Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
            }
        },
        access = access_type_walk_only
    }

    self.unit_categories.RECON_police_heavy = {
        unit_types = {
            america = {
                Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
                Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
            },
            russia = {
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
            },
            zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
                Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
            },
            murkywater = {
                murky_c45
            },
            federales = {
                Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
            }
        },
        access = access_type_walk_only
    }

    -- similar to CS_swat but different for mayhem/death wish
    if difficulty_index == 6 or difficulty_index == 7 then
        self.unit_categories.RECON_swat_smg = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1")
                },
                murkywater = {
                    Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light")
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale")
                }
            },
            access = access_type_all
        }

        self.unit_categories.RECON_swat_shotty = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2")
                },
                murkywater = {
                    Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870")
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870/ene_swat_policia_federale_r870")
                }
            },
            access = access_type_all
        }
    else
        self.unit_categories.RECON_swat_smg = self.unit_categories.CS_swat_MP5
        self.unit_categories.RECON_swat_shotty = self.unit_categories.CS_swat_R870
        
    end

    -- per level modifications
    heist_type = self:getHeistType()
    if heist_type and heist_type == "fbi" then
        self.unit_categories.RECON_light.access = access_type_all
        self.unit_categories.RECON_heavy.access = access_type_all
        --stronger fbi units
        if difficulty_index <= 2 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
            
        elseif difficulty_index <= 4 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }

        elseif difficulty_index <= 6 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }

        else
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }
        end

    elseif heist_type and heist_type == "remote" then
        --replace cops with fbi units in remote heists. doesn't affect overkill+
        self.unit_categories.RECON_light.access = access_type_all
        self.unit_categories.RECON_heavy.access = access_type_all
        if difficulty_index <= 2 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
            }
            self.unit_categories.RECON_light.unit_types.zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1")
            }
            self.unit_categories.RECON_light.unit_types.federales = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }
            self.unit_categories.RECON_heavy.unit_types.zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
            }
            self.unit_categories.RECON_heavy.unit_types.federales = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }
            
        elseif difficulty_index <= 4 and not is_classic then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }
            self.unit_categories.RECON_light.unit_types.zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
            }
            self.unit_categories.RECON_light.unit_types.federales = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
            self.unit_categories.RECON_heavy.unit_types.zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
                Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
            }
            self.unit_categories.RECON_heavy.unit_types.federales = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end

    elseif heist_type and heist_type == "la" then
        --la cops for reservoir dogs, like the scripted spawn
        if difficulty_index <= 2 or (difficulty_index == 3 and is_classic) then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_1/ene_la_cop_1"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4")
            }

        elseif difficulty_index <= 4 and not is_classic then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end

        self.unit_categories.RECON_police_light.unit_types.america = {
            Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_1/ene_la_cop_1"),
            Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2")
        }

        self.unit_categories.RECON_police_heavy.unit_types.america = {
            Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3"),
            Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4")
        }

    elseif heist_type and heist_type == "sanfran" then
        --san francisco cops for the city of light heists
        if difficulty_index <= 2 or (difficulty_index == 3 and is_classic) then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

        elseif difficulty_index <= 4 and not is_classic then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end
        self.unit_categories.RECON_police_light.unit_types.america = {
            Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
            Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
        }

        self.unit_categories.RECON_police_heavy.unit_types.america = {
            Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
            Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
        }
    end
end)

Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "star_recon_init_enemy_spawn_groups", function(self, difficulty_index)
    self._tactics.recon_case = {
        "ranged_fire",
        "provide_coverfire",
        "provide_support",
        "flank"
    }
    self._tactics.recon_rescue = {
        "provide_coverfire",
        "provide_support",
        "flank"
    }
    self._tactics.recon_rescue_leader = {
        "charge",
        "provide_coverfire",
        "provide_support",
        "flank"
    }
    self._tactics.recon_rush = {
        "charge",
        "provide_coverfire",
        "provide_support",
        "deathguard",
        "murder"
    }

    self.enemy_spawn_groups.tac_recon_case = {
        amount = {
            3,
            5
        },
        spawn = {
            {
                amount_min = 2,
                freq = 2,
                amount_max = 4,
                rank = 2,
                unit = "RECON_light",
                tactics = self._tactics.recon_case
            },
            {
                amount_min = 1,
                freq = 1.25,
                amount_max = 2,
                rank = 3,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_case
            }
        }
    }
    self.enemy_spawn_groups.tac_recon_rescue = {
        amount = {
            4,
            4
        },
        spawn = {
            {
                amount_min = 1,
                freq = 1,
                amount_max = 1,
                rank = 3,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_rescue_leader
            },
            {
                amount_min = 0,
                freq = 0.5,
                amount_max = 1,
                rank = 2,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_rescue
            },
            {
                amount_min = 2,
                freq = 1,
                amount_max = 3,
                rank = 1,
                unit = "RECON_light",
                tactics = self._tactics.recon_rescue
            }
        }
    }

    self.enemy_spawn_groups.tac_recon_rush = {
        amount = {
            2,
            3
        },
        spawn = {
            {
                amount_min = 1,
                freq = 1.5,
                amount_max = 2,
                rank = 2,
                unit = "RECON_light",
                tactics = self._tactics.recon_rush
            },
            {
                amount_min = 1,
                freq = 2,
                amount_max = 2,
                rank = 3,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_rush
            }
        }
    }

    self.enemy_spawn_groups.tac_recon_police = {
        amount = {
            3,
            4
        },
        spawn = {
            {
                amount_min = 2,
                freq = 2,
                amount_max = 3,
                rank = 2,
                unit = "RECON_police_light",
                tactics = self._tactics.recon_case
            },
            {
                amount_min = 1,
                freq = 1.25,
                amount_max = 1,
                rank = 3,
                unit = "RECON_police_heavy",
                tactics = self._tactics.recon_case
            }
        }
    }

    self.enemy_spawn_groups.tac_recon_swats = {
        amount = {
            3,
            3
        },
        spawn = {
            {
                amount_min = 2,
                freq = 1,
                amount_max = 3,
                rank = 1,
                unit = "RECON_swat_smg",
                tactics = self._tactics.recon_rescue
            },
            {
                amount_min = 0,
                freq = 1,
                amount_max = 1,
                rank = 2,
                unit = "RECON_swat_smg",
                tactics = self._tactics.recon_rescue_leader
            },
            {
                amount_min = 0,
                freq = 0.5,
                amount_max = 1,
                rank = 2,
                unit = "RECON_swat_smg",
                tactics = self._tactics.recon_rush
            },
            {
                amount_min = 0,
                freq = 0.5,
                amount_max = 1,
                rank = 2,
                unit = "RECON_swat_shotty",
                tactics = self._tactics.recon_rush
            }
        }
    }
    self.enemy_spawn_groups.tac_reenforce_2lights = {
        amount = {
            2,
            2
        },
        spawn = {
            {
                amount_min = 2,
                freq = 1,
                amount_max = 2,
                rank = 1,
                unit = "RECON_light",
                tactics = self._tactics.recon_case
            }
        }
    }
    self.enemy_spawn_groups.tac_reenforce_1heavy = {
        amount = {
            1,
            1
        },
        spawn = {
            {
                amount_min = 1,
                freq = 1,
                amount_max = 1,
                rank = 2,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_case
            }
        }
    }
    self.enemy_spawn_groups.tac_reenforce_2heavies = {
        amount = {
            2,
            2
        },
        spawn = {
            {
                amount_min = 2,
                freq = 1,
                amount_max = 2,
                rank = 2,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_rush
            }
        }
    }
    self.enemy_spawn_groups.tac_reenforce_team = {
        amount = {
            3,
            3
        },
        spawn = {
            {
                amount_min = 2,
                freq = 1,
                amount_max = 2,
                rank = 1,
                unit = "RECON_light",
                tactics = self._tactics.recon_rescue
            },
            {
                amount_min = 1,
                freq = 1,
                amount_max = 1,
                rank = 2,
                unit = "RECON_heavy",
                tactics = self._tactics.recon_rescue_leader
            }
        }
    }
    self.enemy_spawn_groups.tac_reenforce_police = {
        amount = {
            2,
            2
        },
        spawn = {
            {
                amount_min = 1,
                freq = 1.5,
                amount_max = 2,
                rank = 1,
                unit = "RECON_police_light",
                tactics = self._tactics.recon_case
            },
            {
                amount_min = 1,
                freq = 1,
                amount_max = 2,
                rank = 1,
                unit = "RECON_police_heavy",
                tactics = self._tactics.recon_case
            }
        }
    }
end)

Hooks:PostHook(GroupAITweakData, "_init_task_data", "star_recon_init_task_data", function(self, difficulty_index, difficulty)
    -- let them respawn faster so maybe you'll actually get to engage them
    self.besiege.recon.interval = {
        5,
        3,
        1
    }
    self.besiege.recon.interval_variation = 0

    self.besiege.recon.force = {
        3,
        6,
        10
    }

    local heist_type = self:getHeistType()
    if heist_type == "fbi" then
        -- more units if attacking fbi building
        self.besiege.recon.force = {
            4,
            8,
            12
        }
    end

    self.besiege.recon.groups = {
        tac_recon_case = {
            1,
            0.6,
            0.3
        },
        tac_recon_rescue = {
            0,
            0.3,
            0.4
        },
        tac_recon_rush = {
            0,
            0.1,
            0.3
        },
        single_spooc = {
            0,
            0,
            0
        },
        Phalanx = {
            0,
            0,
            0
        }
    }
    
    if self.rtre_menu_data then
        local reenforce_valid = (self.rtre_menu_data.assault_behaviour and self.rtre_menu_data.assault_behaviour > 1)
        --reenforce
        if reenforce_valid then
            self.besiege.reenforce.groups = {
                tac_reenforce_2lights = {
                    0.6,
                    0.3,
                    0
                },
                tac_reenforce_1heavy = {
                    0.4,
                    0.2,
                    0
                },
                tac_reenforce_2heavies = {
                    0,
                    0.2,
                    0.4
                },
                tac_reenforce_team = {
                    0,
                    0.3,
                    0.6
                },
                single_spooc = {
                    0,
                    0,
                    0
                },
                Phalanx = {
                    0,
                    0,
                    0
                }
            }
        end
        --classic enemy set
        if self.rtre_menu_data.enemy_set == 3 then
            if difficulty_index <= 3 and heist_type ~= "fbi" then
                --reset groups
                self.besiege.recon.groups = {
                    single_spooc = {
                        0,
                        0,
                        0
                    },
                    Phalanx = {
                        0,
                        0,
                        0
                    }
                }
                if reenforce_valid then 
                    self.besiege.reenforce.groups = {
                        single_spooc = {
                            0,
                            0,
                            0
                        },
                        Phalanx = {
                            0,
                            0,
                            0
                        }
                    }
                end
                -- remote heists below VH have just swat
                if heist_type == "remote" then
                    self.besiege.recon.groups.tac_recon_swats = {
                        1,
                        1,
                        1
                    }
                    
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            1,
                            1,
                            1
                        }
                    end
                --normal diff
                elseif difficulty_index <= 2 then
                    self.besiege.recon.groups.tac_recon_police = {
                        1,
                        1,
                        0
                    }
                    self.besiege.recon.groups.tac_recon_swats = {
                        0,
                        0,
                        1
                    }
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_reenforce_police = {
                            1,
                            1,
                            0
                        }
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            0,
                            0,
                            1
                        }
                    end
                -- hard diff
                else 
                    self.besiege.recon.groups.tac_recon_police = {
                        1,
                        0.5,
                        0
                    }
                    self.besiege.recon.groups.tac_recon_swats = {
                        0,
                        0.5,
                        1
                    }
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_reenforce_police = {
                            1,
                            0.5,
                            0
                        }
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            0,
                            0.5,
                            1
                        }
                    end
                end
            -- vh diff
            elseif difficulty_index <= 4 then
                -- final groups
                self.besiege.recon.groups = {
                    tac_recon_case = {
                        0,
                        0,
                        0.6
                    },
                    tac_recon_rescue = {
                        0,
                        0,
                        0.3
                    },
                    tac_recon_rush = {
                        0,
                        0,
                        0.1
                    },
                    single_spooc = {
                        0,
                        0,
                        0
                    },
                    Phalanx = {
                        0,
                        0,
                        0
                    }
                }

                if reenforce_valid then
                    self.besiege.reenforce.groups = {
                        tac_reenforce_2lights = {
                            0,
                            0,
                            0.3
                        },
                        tac_reenforce_1heavy = {
                            0,
                            0,
                            0.2
                        },
                        tac_reenforce_2heavies = {
                            0,
                            0,
                            0.2
                        },
                        tac_reenforce_team = {
                            0,
                            0,
                            0.3
                        },
                        single_spooc = {
                            0,
                            0,
                            0
                        },
                        Phalanx = {
                            0,
                            0,
                            0
                        }
                    }
                end
                -- remote heists will not have any cops below 0.5 diff. other heists will
                if heist_type == "remote" then
                    self.besiege.recon.groups.tac_recon_swats = {
                        1,
                        1,
                        0
                    }
                    
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            1,
                            1,
                            0
                        }
                    end
                else
                    self.besiege.recon.groups.tac_recon_police = {
                        0.5,
                        0,
                        0
                    }
                    self.besiege.recon.groups.tac_recon_swats = {
                        0.5,
                        1,
                        0
                    }
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_reenforce_police = {
                            0.5,
                            0,
                            0
                        }
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            0.5,
                            1,
                            0
                        }
                    end
                end
            else
                -- add cops and swats to difficulties overkill and above. no cops on remote heists
                if heist_type == "remote" or heist_type == "fbi" then
                    self.besiege.recon.groups.tac_recon_swats = {
                        0.5,
                        0,
                        0
                    }
                    
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            0.5,
                            0,
                            0
                        }
                    end
                else
                    self.besiege.recon.groups.tac_recon_police = {
                        0.15,
                        0,
                        0
                    }
                    self.besiege.recon.groups.tac_recon_swats = {
                        0.35,
                        0,
                        0
                    }
                    if reenforce_valid then
                        self.besiege.reenforce.groups.tac_reenforce_police = {
                            0.15,
                            0,
                            0
                        }
                        self.besiege.reenforce.groups.tac_recon_swats = {
                            0.35,
                            0,
                            0
                        }
                    end
                end
            end
        end
    end
    
    -- reclone
    self.street = deep_clone(self.besiege)
    self.safehouse = deep_clone(self.besiege)
end)