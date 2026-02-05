local tweak_data_ref = nil
local data_path = SavePath .. "ReconTaskRestoredAndExpanded.json"

function GroupAITweakData:getHeistType()
    
end

Hooks:PreHook(GroupAITweakData, "init", "star_recon_init_groupaitweakdata", function(self, tweak_data)
    tweak_data_ref = tweak_data
    self.rtre_menu_data = {}
    self._enemy_sets = {
        STANDARD = 1,
        FIXED_DIFF = 2,
        FIXED = 3,
        SWAT = 4,
        NONE = 5,
        ORIGINAL = 6
    }
    
    -- get menu data
    local file = io.open( data_path, "r" )
    if file then
        self.rtre_menu_data = json.decode( file:read("*all") )
        file:close()
    end-
    --enemies
    if not self.rtre_menu_data.no_lights then self.rtre_menu_data.no_lights = false end
    if not self.rtre_menu_data.bronco_guy then self.rtre_menu_data.bronco_guy = false end

    self._RTRE_LEVEL_FACTION = Global.level_data and Global.level_data.level_id and tweak_data_ref.levels[Global.level_data.level_id].ai_group_type
    
    if not self._RTRE_LEVEL_FACTION then self._RTRE_LEVEL_FACTION = "america" end

    if self._RTRE_LEVEL_FACTION == "russia" then
        self.rtre_menu_data.enemy_set = self.rtre_menu_data.enemy_set_russia
    elseif self._RTRE_LEVEL_FACTION == "zombie" then
        self.rtre_menu_data.enemy_set = self.rtre_menu_data.enemy_set_zombie
    elseif self._RTRE_LEVEL_FACTION == "murkywater" then
        self.rtre_menu_data.enemy_set = self.rtre_menu_data.enemy_set_murky
    elseif self._RTRE_LEVEL_FACTION == "federales" then
        self.rtre_menu_data.enemy_set = self.rtre_menu_data.enemy_set_federales
    else
        self.rtre_menu_data.enemy_set = self.rtre_menu_data.enemy_set_america
    end

    if not self.rtre_menu_data.enemy_set then self.rtre_menu_data.enemy_set = self._enemy_sets.STANDARD end

    local level_id = Global.level_data and Global.level_data.level_id -- referenced from Assault Tweaks Standalone
    
    --remote heists always use hostage rescue team with no light enemies, and guarantee full access
    if level_id == "firestarter_2" or level_id == "hox_2" or level_id == "hox_3" then
        self._RTRE_FBI_HEIST = true
    end
    if self._RTRE_FBI_HEIST or self._RTRE_LEVEL_FACTION == "murkywater" or level_id == "welcome_to_the_jungle_2" or level_id == "chew" or level_id == "chca" or level_id == "trai" or level_id == "deep" or (self.rtre_menu_data and self.rtre_menu_data.no_lights) then
        self._RTRE_REMOTE_HEIST = true
    end

    if level_id == "wrvd1" or level_id == "rvd2" then
        self._RTRE_LEVEL_SUBFACTION = "la"
    elseif level_id == "chas" or level_id == "sand" or level_id == "pent" then
        self._RTRE_LEVEL_SUBFACTION = "sanfran"
    elseif level_id == "ranc" or level_id == "corp" then
        self._RTRE_LEVEL_SUBFACTION = "texas"
    else
        self._RTRE_LEVEL_SUBFACTION = "normal"
    end
end)


Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "star_recon_init_unit_categories", function(self, difficulty_index)
    local access_type_walk_only = {
		walk = true
	}
    local access_type_all = {
		acrobatic = true,
		walk = true
	}

    local mission = self:getHeistType()
    
    local cop_table = {
        normal = {
            c45 = Idstring("units/payday2/characters/ene_1/ene_1"),
            bronco = Idstring("units/payday2/characters/ene_2/ene_2"),
            mp5 = Idstring("units/payday2/characters/ene_3/ene_3"),
            r870 = Idstring("units/payday2/characters/ene_4/ene_4")
        },
        la = {
            c45 = Idstring("units/pd2_dlc_rvd/characters/ene_la_1/ene_la_1"),
            bronco = Idstring("units/pd2_dlc_rvd/characters/ene_la_2/ene_la_2"),
            mp5 = Idstring("units/pd2_dlc_rvd/characters/ene_la_3/ene_la_3"),
            r870 = Idstring("units/pd2_dlc_rvd/characters/ene_la_4/ene_la_4")
        },
        sanfran = {
            c45 = Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
            bronco = Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02"),
            mp5 = Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_01/ene_male_chas_police_01"),
            r870 = Idstring("units/pd2_dlc_chas/characters/ene_male_chas_police_02/ene_male_chas_police_02")
        },
        texas = {
            c45 = Idstring("units/pd2_dlc_ranc/characters/ene_male_ranc_ranger_01/ene_male_ranc_ranger_01"),
            bronco = Idstring("units/pd2_dlc_ranc/characters/ene_male_ranc_ranger_02/ene_male_ranc_ranger_02"),
            mp5 = Idstring("units/pd2_dlc_ranc/characters/ene_male_ranc_ranger_01/ene_male_ranc_ranger_01"),
            r870 = Idstring("units/pd2_dlc_ranc/characters/ene_male_ranc_ranger_02/ene_male_ranc_ranger_02")
        }
    }

    local cop_units = cop_table[self._RTRE_LEVEL_SUBFACTION]
    if self._RTRE_LEVEL_SUBFACTION == "texas" or self._RTRE_LEVEL_SUBFACTION == "sanfran" then
        cop_units.hard_mp5 = Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
        cop_units.hard_r870 = Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
    else {
        cop_units.hard_mp5 = cop_units.mp5
        cop_units.hard_r870 = cop_units.r870
    }

    local murky_units = {
        mp5 = Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light")
    }

    local pkg = tweak_data_ref and Global.level_data and Global.level_data.level_id and tweak_data_ref.levels[Global.level_data.level_id].package
    local level_package = {}
    if type(pkg) == "table" then
        for _, package in pairs(pkg) {
            level_package[package] = true
        }
    else
        level_package = {
            [pkg] = true
        }
    end
    
    if level_package["packages/job_mex"] or level_package["packages/job_mex2"] or level_package["packages/job_des"] then
        murky_units.scar = Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_2/ene_murkywater_not_security_2")
        murky_units.ump = Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_1/ene_murkywater_not_security_1")
        murky_units.cop = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
    else
        murky_units.scar = Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security")
        murky_units.ump = murky_units.scar
        if level_package["packages/narr_jerry1"] or level_package["packages/dlcs/vit/job_vit"] then
            murky_units.cop = Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service")
        else
            murky_units.cop = murky_units.mp5
        end
    end

    -- init reg cops
    self.unit_categories.RECON_cop_light = {
        unit_types = {
            america = {
                cop_units.c45,
                cop_units.bronco
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
                murky_units.cop
            },
            federales = {
                Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
            }
        },
        access = access_type_walk_only
    }

    self.unit_categories.RECON_cop_heavy = {
            unit_types = {
                america = {
                    cop_units.mp5,
                    copy_units.r870
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
                    murky_units.cop
                },
                federales = {
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                    Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
                }
            },
            access = access_type_walk_only
        }

    -- init recon swat
    if difficulty_index == 6 or difficulty_index == 7 then
        self.unit_categories.RECON_swat_mp5 = {
            unit_types = {
                america = {
                    Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass")
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
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870")
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
    elseif difficulty_index == 8 then
        self.unit_categories.RECON_swat_mp5 = {
            unit_types = {
                america = {
                    Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass")
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
                    Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat")
                },
                russia = {
                    Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870")
                },
                zombie = {
                    Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2")
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
    else
        self.unit_categories.RECON_swat_mp5 = {
			access = access_type_all,
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
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
			}
		}
        self.unit_categories.RECON_swat_shotty = {
			access = access_type_all,
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2")
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
			}
		}
    end

    -- init hostage rescue team
    if difficulty_index <= 2 and not self._RTRE_FBI_HEIST and self.rtre_menu_data.enemy_set ~= self._enemy_sets.FIXED then
        -- not used in standard
        if self._RTRE_REMOTE_HEIST then
            -- normal difficulty fixed remote units
            self.unit_categories.RECON_light = {
                unit_types = {
                    america = {
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1")
                    },
                    murkywater = {
                        murky_units.mp5
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
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
                        murky_units.mp5
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")

                    }
                },
                access = access_type_all
            }
        else
            
            -- normal difficulty fixed standard police units
            self.unit_categories.RECON_light = self.unit_categories.RECON_police_light
            self.unit_categories.RECON_heavy = self.unit_categories.RECON_police_heavy
        end
    elseif difficulty_index <= 4 and ((self.rtre_menu_data.enemy_set == self._enemy_sets.FIXED_DIFF and not self._RTRE_FBI_HEIST) or difficulty_index <= 2)  then
        if self._RTRE_REMOTE_HEIST then
            -- fixed hard/vh remote units or normal difficulty FBI heist HRT. on standard enemy set, very hard uses the next tier of hostage rescue team
            self.unit_categories.RECON_light = {
                unit_types = {
                    america = {
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
                    },
                    murkywater = {
                        murky_units.mp5
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                    }
                },
                access = access_type_all
            }

            self.unit_categories.RECON_heavy = {
                unit_types = {
                    america = {
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
                    },
                    murkywater = {
                        murky_units.ump
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                    }
                },
                access = access_type_all
            }
        else
            -- fixed hard/vh standard police units with FBI assistance
            self.unit_categories.RECON_light = {
                unit_types = {
                    america = {
                        cop_units.bronco,
                        cop_units.mp5,
                        cop_units.r870
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
                    },
                    murkywater = {
                        murky_units.mp5
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
                        cop_units.hard_mp5,
                        cop_units.hard_smg
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")

                    },
                    murkywater = {
                        murky_units.ump

                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                        Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")

                    }
                },
                access = access_type_walk_only
            }
        end
    elseif difficulty_index <= 6 then
        if self._RTRE_FBI_HEIST then
            if self.rtre_menu_data.enemy_set == self._enemy_sets.FIXED then
                --FBI heist units for difficulty-independent fixed units
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
                            murky_units.ump
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
                            murky_units.scar
                        },
                        federales = {
                            Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")

                        }
                    },
                    access = access_type_all
                }
            elseif difficulty_index > 4
                --FBI heist units for OVK/MH
                self.unit_categories.RECON_light = {
                    unit_types = {
                        america = {
                            Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                            Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                        },
                        russia = {
                            Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                            Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                        },
                        zombie = {
                            Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3"),
                            Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
                        },
                        murkywater = {
                            murky_units.ump,
                            murky_units.scar
                        },
                        federales = {
                            Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                            Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                        }
                    },
                    access = access_type_all
                }

                self.unit_categories.RECON_heavy = {
                    unit_types = {
                        america = {
                            Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                        },
                        russia = {
                            Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
                            Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870")
                        },
                        zombie = {
                            Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
                        },
                        murkywater = {
                            murky_units.ump
                        },
                        federales = {
                            Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
                        }
                    },
                    access = access_type_all
                }
            end
        else
            -- standard HRT for VH/OVK/MH, fixed units for OVK/MH, H/VH HRT/units on FBI heists, and also non-difficulty-dependent fixed units
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
                        murky_units.mp5,
                        murky_units.ump
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
                        murky_units.ump,
                        murky_units.scar
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")

                    }
                },
                access = access_type_all
            }
        end
    else
        if self._RTRE_FBI_HEIST then
            --FBI heist units for DW/DS
            self.unit_categories.RECON_light = {
                unit_types = {
                    america = {
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                    },
                    russia = {
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                        Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
                    },
                    zombie = {
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3"),
                        Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
                    },
                    murkywater = {
                        murky_units.ump,
                        murky_units.scar
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
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
                        murky_units.scar
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
                    }
                },
                access = access_type_all
            }
        else
            --standard HRT and fixed units for DW/DS
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
                        murky_units.ump
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
                        murky_units.scar
                    },
                    federales = {
                        Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")

                    }
                },
                access = access_type_all
            }
        end
    end

    self.unit_categories.RECON_bronco_guy = {
        unit_types = {
            america = {
                cop_units.bronco
            },
            russia = {
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
                Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
            },
            zombie = {
                Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2")
            },
            murkywater = {
                murky_units.cop
            },
            federales = {
                Idstring("units/pd2_dlc_bex/characters/ene_policia_01/ene_policia_01"),
                Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02")
            }
        },
        access = access_type_walk_only
    }

end)