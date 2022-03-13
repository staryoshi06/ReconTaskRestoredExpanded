Hooks:PostHook(ElementSpawnEnemyGroup, "init", "star_recon_init_spawn_group_element", function(self, ...)
    local groups = self._values.preferred_spawn_groups

    if groups ~= nil then
        for k, v in pairs(groups) do
            if v == "tac_swat_rifle_flank" then
                table.insert(groups, "tac_recon_rescue")
                table.insert(groups, "tac_recon_rush")
                table.insert(groups, "tac_recon_police_rescue")
                table.insert(groups, "tac_recon_police_rush")
                table.insert(groups, "tac_recon_swats")
                break
            end
        end
    end
    --testing
    --for k, v in pairs(groups) do
        --log("Key: " .. k .. " Data: " .. v)
    --end
end)