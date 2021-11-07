local tweak_data_ref = nil

function getHeistType()
    local level_id = Global.level_data and Global.level_data.level_id -- referenced from Assault Tweaks Standalone

    if not level_id then
        return nil
    elseif level_id == "firestarter_2" or level_id == "hox_2" or level_id == "hox_3" then
        return "fbi"
    elseif level_id == "welcome_to_the_jungle_2" or level_id == "chew" or level_id == "chca" then
        return "remote"
    elseif level_id == "rvd1" or level_id == "rvd2" then
        return "la"
    elseif level_id == "chas" or level_id == "sand" then
        return "sanfran"
    else
        return "normal"
    end
end

Hooks:PreHook(GroupAITweakData, "init", "star_recon_init_groupaitweakdata", function(self, tweak_data)
    tweak_data_ref = tweak_data
end)

--Define recon units and add to original
Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "star_recon_init_unit_categories", function(self, difficulty_index)
    local access_type_all = {
		acrobatic = true,
		walk = true
	}

    --check for whether required packages are loaded for murky units. if not, swap out
    --if we don't then host will crash. if we force load packages, clients without mod will not see enemies
    --I don't know the memory cost of checking this unfortunately
    local murky_scar = nil
    local murky_c45 = nil
    local murky_ump = nil

    --from gamesetup.lua
    local lvl_tweak_data = tweak_data_ref and Global.level_data and Global.level_data.level_id and tweak_data_ref.levels[Global.level_data.level_id]
    local level_package = lvl_tweak_data and lvl_tweak_data.package

    if type(level_package) == "table" then
        for _, package in ipairs(level_package) do
            if not murky_scar and (package == "packages/job_mex" or package == "packages/job_mex2" or package == "packages/job_des") then
                murky_scar = Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_2/ene_murkywater_not_security_2")
            end
    
            if not murky_c45 and (murky_scar or (package == "packages/narr_jerry1" or package == "packages/dlcs/vit/job_vit")) then
                murky_c45 = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
            end
    
            if not murky_ump and (murky_scar or murky_c45 or package == "packages/dlcs/bph/job_bph") then
                murky_ump = Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security")
            end
        end
    else
        if level_package and (level_package == "packages/job_mex" or level_package == "packages/job_mex2" or level_package == "packages/job_des") then
            murky_scar = Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_2/ene_murkywater_not_security_2")
        end

        if murky_scar or (level_package and (level_package == "packages/narr_jerry1" or level_package == "packages/dlcs/vit/job_vit")) then
            murky_c45 = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
        end

        if murky_scar or murky_c45 or (level_package and level_package == "packages/dlcs/bph/job_bph") then
            murky_ump = Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security")
        end
    end

    if not murky_ump then
        --account for custom packages
        murky_ump = Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light")
    end
    if not murky_scar then
        murky_scar = murky_ump
    end
    if not murky_c45 then
        murky_c45 = murky_ump
    end

    --Normal
    if (difficulty_index <= 2) then
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
            access = access_type_all
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
            access = access_type_all
        }

    --Hard/Very Hard
    elseif (difficulty_index <= 4) then
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
            access = access_type_all
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
                    murky_ump

                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                    Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")

                }
            },
            access = access_type_all
        }

    --Overkill/Mayhem
    elseif (difficulty_index <= 6) then
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
                    murky_ump
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
                    murky_ump,
                    murky_scar
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
                    murky_ump
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
                    murky_scar
                },
                federales = {
                    Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                }
            },
            access = access_type_all
        }
    end

    -- per level modifications
    heist_type = getHeistType()
    if heist_type and heist_type == "fbi" then
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
        if difficulty_index <= 2 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }
            
        elseif difficulty_index <= 4 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end

    elseif heist_type and heist_type == "la" then
        --la cops for reservoir dogs, like the scripted spawn
        if difficulty_index <= 2 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_1/ene_la_cop_1"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4")
            }

        elseif difficulty_index <= 4 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3"),
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end

    elseif heist_type and heist_type == "sanfran" then
        --san francisco cops for the city of light heists
        if difficulty_index <= 2 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

        elseif difficulty_index <= 4 then
            self.unit_categories.RECON_light.unit_types.america = {
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
                Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
            }

            self.unit_categories.RECON_heavy.unit_types.america = {
                Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
            }
        end
    end
end)

Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "star_recon_init_enemy_spawn_groups", function(self, difficulty_index)
    self._tactics.recon_rescue = {
        "ranged_fire",
        "provide_coverfire",
        "provide_support",
        "flank"
    }
    self._tactics.recon_rush = {
        "charge",
        "provide_coverfire",
        "provide_support",
        "deathguard"
    }

    self.enemy_spawn_groups.tac_recon_rescue = {
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
                tactics = self._tactics.recon_rescue
            },
            {
                amount_min = 1,
                freq = 1.25,
                amount_max = 2,
                rank = 3,
                unit = "RECON_heavy",
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

    heist_type = getHeistType()
    if heist_type and heist_type == "fbi" then
        -- more units if attacking fbi building
        self.besiege.recon.force = {
            4,
            8,
            12
        }
    end

    self.besiege.recon.groups = {
        tac_recon_rescue = {
            1,
            0.8,
            0.6
        },
        tac_recon_rush = {
            0,
            0.2,
            0.4
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
    
    -- reclone
    self.street = deep_clone(self.besiege)
    self.safehouse = deep_clone(self.besiege)
end)